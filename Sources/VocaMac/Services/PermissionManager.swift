// PermissionManager.swift
// VocaMac
//
// Manages system permission checking, requesting, and polling.
// Extracts permission logic from AppState for focused responsibility.

import Foundation
import AppKit
import Combine

/// Manages system permissions: microphone, accessibility, and input monitoring.
///
/// Accessibility and Input Monitoring permissions don't provide callback-based APIs,
/// so this manager polls to detect changes when the user grants access in System Settings.
@MainActor
final class PermissionManager: ObservableObject {

    // MARK: - Published State

    /// Microphone permission status
    @Published var micPermission: PermissionStatus = .notDetermined

    /// Accessibility permission status
    @Published var accessibilityPermission: PermissionStatus = .notDetermined

    /// Input Monitoring permission status
    @Published var inputMonitoringPermission: PermissionStatus = .notDetermined

    // MARK: - Dependencies

    private let audioEngine: AudioRecording
    private let hotKeyManager: HotKeyMonitoring

    // MARK: - Private

    private var permissionPollTimer: Timer?

    /// Tracks the first-launch permission wizard so prompts appear one at a time.
    private enum InitialPermissionSequencePhase: Equatable {
        case inactive
        case requestingMicrophone
        case awaitingAccessibilityGrant
        case awaitingInputMonitoringGrant
    }

    private var initialSequencePhase: InitialPermissionSequencePhase = .inactive
    private static let interPromptDelayNanoseconds: UInt64 = 500_000_000

    /// When true, `checkInputMonitoringPermission()` skips creating event taps.
    /// Event tap probes trigger the "Keystroke Receiving" system dialog, which must
    /// not appear while the microphone prompt is still on screen.
    private var suppressInputMonitoringProbe = false

    var onAllPermissionsGranted: (() -> Void)?

    // MARK: - Initialization

    init(audioEngine: AudioRecording, hotKeyManager: HotKeyMonitoring) {
        self.audioEngine = audioEngine
        self.hotKeyManager = hotKeyManager
    }

    // MARK: - Permission Checking

    /// Whether all required permissions are granted.
    var allPermissionsGranted: Bool {
        micPermission == .granted &&
        accessibilityPermission == .granted &&
        inputMonitoringPermission == .granted
    }

    /// Re-check all permission statuses from the system.
    func checkPermissions() {
        micPermission = audioEngine.checkPermissionStatus()

        let accessibilityGranted = hotKeyManager.checkAccessibilityPermission(prompt: false)
        accessibilityPermission = accessibilityGranted ? .granted : .denied

        let inputMonitoringGranted = checkInputMonitoringPermission()
        inputMonitoringPermission = inputMonitoringGranted ? .granted : .denied
    }

    /// Check Input Monitoring permission using multiple strategies since no
    /// single approach is 100% reliable:
    /// 1. If HotKeyManager created a tap, check if macOS has disabled it (revocation)
    /// 2. Try creating a fresh `.cghidEventTap` (same type HotKeyManager uses)
    private func checkInputMonitoringPermission() -> Bool {
        if suppressInputMonitoringProbe {
            return false
        }

        // Strategy 1: If HotKeyManager has an active tap, check if macOS disabled it.
        if hotKeyManager.isListening, let tap = hotKeyManager.eventTap {
            return CGEvent.tapIsEnabled(tap: tap)
        }

        // Strategy 2: Try creating a fresh .cghidEventTap — the same type
        // HotKeyManager uses. More accurate than .cgSessionEventTap which
        // may inherit Terminal's permissions when launched from CLI.
        let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: { _, _, event, _ in Unmanaged.passRetained(event) },
            userInfo: nil
        )
        if let tap = tap {
            CFMachPortInvalidate(tap)
            return true
        }
        return false
    }

    // MARK: - Initial Permission Sequence

    /// Call before any permission checks on first launch so event-tap probes
    /// (which trigger the "Keystroke Receiving" dialog) are deferred until the
    /// sequential flow reaches the input-monitoring step.
    func prepareInitialPermissionSequence() {
        suppressInputMonitoringProbe = true
        VocaLogger.debug(.appState, "Prepared initial permission sequence — suppressing input monitoring probes")
    }

    /// On first launch, request permissions one at a time: microphone first,
    /// then accessibility, then input monitoring.
    func requestInitialPermissionsSequentiallyIfNeeded(isFirstLaunch: Bool) {
        guard isFirstLaunch else { return }
        guard initialSequencePhase == .inactive else { return }

        checkPermissions()
        guard !allPermissionsGranted else { return }

        VocaLogger.info(.appState, "Starting sequential initial permission flow")

        if micPermission == .notDetermined {
            initialSequencePhase = .requestingMicrophone
            audioEngine.requestPermission { [weak self] granted in
                Task { @MainActor in
                    self?.handleInitialMicrophoneResult(granted)
                }
            }
            return
        }

        if micPermission == .granted {
            Task { @MainActor in
                await self.promptAccessibilityIfNeeded()
            }
            return
        }

        // Microphone already denied — don't chain further system prompts.
        suppressInputMonitoringProbe = false
        startPermissionPolling()
    }

    private func handleInitialMicrophoneResult(_ granted: Bool) {
        micPermission = granted ? .granted : .denied

        guard granted else {
            VocaLogger.info(.appState, "Microphone denied — stopping initial permission sequence")
            suppressInputMonitoringProbe = false
            initialSequencePhase = .inactive
            startPermissionPolling()
            return
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: Self.interPromptDelayNanoseconds)
            await self.promptAccessibilityIfNeeded()
        }
    }

    private func promptAccessibilityIfNeeded() async {
        guard initialSequencePhase == .inactive ||
              initialSequencePhase == .requestingMicrophone else { return }

        checkPermissions()

        if accessibilityPermission == .granted {
            initialSequencePhase = .awaitingInputMonitoringGrant
            await promptInputMonitoringIfNeeded()
            return
        }

        initialSequencePhase = .awaitingAccessibilityGrant
        let _ = hotKeyManager.checkAccessibilityPermission(prompt: true)
        VocaLogger.info(.appState, "Prompted for Accessibility permission")
        startPermissionPolling()
    }

    private func promptInputMonitoringIfNeeded() async {
        guard initialSequencePhase == .awaitingInputMonitoringGrant else { return }

        // Probes were suppressed while microphone/accessibility prompts were active.
        suppressInputMonitoringProbe = false
        checkPermissions()

        if inputMonitoringPermission == .granted {
            finishInitialPermissionSequence()
            return
        }

        requestInputMonitoringPermission()
        VocaLogger.info(.appState, "Prompted for Input Monitoring permission")
        startPermissionPolling()
    }

    private func finishInitialPermissionSequence() {
        VocaLogger.info(.appState, "Initial permission sequence complete")
        suppressInputMonitoringProbe = false
        initialSequencePhase = .inactive
        checkPermissions()

        if accessibilityPermission == .granted,
           inputMonitoringPermission == .granted,
           !hotKeyManager.isListening {
            onAllPermissionsGranted?()
        }
    }

    private func handleInitialSequencePollingUpdate() {
        switch initialSequencePhase {
        case .inactive, .requestingMicrophone:
            break
        case .awaitingAccessibilityGrant:
            guard accessibilityPermission == .granted else { return }
            initialSequencePhase = .awaitingInputMonitoringGrant
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: Self.interPromptDelayNanoseconds)
                await self.promptInputMonitoringIfNeeded()
            }
        case .awaitingInputMonitoringGrant:
            if inputMonitoringPermission == .granted {
                finishInitialPermissionSequence()
            }
        }
    }

    // MARK: - Permission Requests

    /// Request microphone permission. Opens System Settings if already denied.
    func requestMicrophonePermission() {
        if micPermission == .denied {
            openMicrophoneSettings()
            return
        }

        audioEngine.requestPermission { [weak self] granted in
            Task { @MainActor in
                self?.micPermission = granted ? .granted : .denied
            }
        }
    }

    /// Open the Microphone privacy pane in System Settings.
    func openMicrophoneSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
            NSWorkspace.shared.open(url)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.checkPermissions()
        }
    }

    /// Prompt the user to grant Accessibility permission.
    func requestAccessibilityPermission() {
        let _ = hotKeyManager.checkAccessibilityPermission(prompt: true)
        startPermissionPolling()
    }

    /// Trigger Input Monitoring permission dialog and open System Settings.
    func requestInputMonitoringPermission() {
        // Attempting to create an event tap triggers macOS to auto-add
        // the app to the Input Monitoring list in System Settings.
        let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: { _, _, event, _ in Unmanaged.passRetained(event) },
            userInfo: nil
        )
        if let tap = tap {
            CFMachPortInvalidate(tap)
        }

        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
            NSWorkspace.shared.open(url)
        }

        startPermissionPolling()
    }

    // MARK: - Permission Polling

    /// Start polling permissions every 3 seconds until all are granted.
    func startPermissionPolling() {
        guard permissionPollTimer == nil else { return }
        guard !allPermissionsGranted else { return }

        VocaLogger.debug(.appState, "Starting permission polling")
        permissionPollTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.checkPermissions()
                self.handleInitialSequencePollingUpdate()

                // Notify when all permissions granted and hotkey can start
                if self.accessibilityPermission == .granted &&
                    self.inputMonitoringPermission == .granted &&
                    !self.hotKeyManager.isListening {
                    self.onAllPermissionsGranted?()
                }

                if self.allPermissionsGranted {
                    self.stopPermissionPolling()
                }
            }
        }
    }

    /// Stop the permission polling timer.
    func stopPermissionPolling() {
        VocaLogger.debug(.appState, "Stopping permission polling — all permissions granted")
        permissionPollTimer?.invalidate()
        permissionPollTimer = nil
    }
}

// MARK: - PermissionManaging Conformance

extension PermissionManager: PermissionManaging {
    var objectWillChangePublisher: AnyPublisher<Void, Never> {
        objectWillChange.eraseToAnyPublisher()
    }
}
