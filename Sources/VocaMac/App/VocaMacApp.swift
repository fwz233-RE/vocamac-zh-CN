// VocaMacApp.swift
// VocaMac
//
// Main entry point for the VocaMac application.
// Configures the app as a menu bar-only application (no Dock icon).

import SwiftUI

/// Manages the settings window for menu-bar-only apps
final class SettingsWindowManager: ObservableObject {
    private var settingsWindow: NSWindow?

    func open(appState: AppState) {
        // If window already exists, just bring it to front
        if let window = settingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create the settings view
        let settingsView = SettingsView()
            .environmentObject(appState)

        // Create a new window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 480),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "VocaMac 设置"
        window.contentView = NSHostingView(rootView: settingsView)
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)

        self.settingsWindow = window

        // Temporarily show in dock so the window can receive focus
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        // Watch for window close to hide from dock again
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.settingsWindow = nil
            // Hide from dock again when settings closes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
}

/// Manages the onboarding window
@MainActor
final class OnboardingWindowManager: ObservableObject {
    private var onboardingWindow: NSWindow?
    var onCompletion: (() -> Void)?

    func open(appState: AppState, force: Bool = false) {
        // If window already exists, just bring it to front
        if let window = onboardingWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // When manually re-triggered, reset completion flag so the
        // monitor doesn't immediately close the window
        if force {
            appState.hasCompletedOnboarding = false
        }

        // Create the onboarding view
        let onboardingView = OnboardingView()
            .environmentObject(appState)

        // Create a new window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 580),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "欢迎使用 VocaMac"
        window.contentView = NSHostingView(rootView: onboardingView)
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)

        self.onboardingWindow = window

        // Show in dock
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        // Watch for window close
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.onboardingWindow = nil
                // Hide from dock when onboarding closes
                try? await Task.sleep(nanoseconds: 500_000_000)
                NSApp.setActivationPolicy(.accessory)
            }
        }

        // Monitor app state for onboarding completion on main thread
        DispatchQueue.main.async {
            self.monitorOnboardingCompletion(appState: appState)
        }
    }

    private func monitorOnboardingCompletion(appState: AppState) {
        Task {
            while self.onboardingWindow?.isVisible == true {
                await MainActor.run {
                    if appState.hasCompletedOnboarding {
                        self.onboardingWindow?.close()
                    }
                }
                try? await Task.sleep(nanoseconds: 100_000_000)  // Check every 100ms
            }
        }
    }
}

@main
struct VocaMacApp: App {
    @StateObject private var appState = AppState.production()
    @StateObject private var settingsManager = SettingsWindowManager()
    @StateObject private var onboardingManager = OnboardingWindowManager()
    /// Tracks whether the user has kept VocaMac in the menu bar (system sets false on removal).
    @State private var menuBarInserted = true
    /// Used with `onChange` to detect transitions out of recording (macOS 13 API).
    @State private var wasRecordingForMenuBar = false

    /// Hides the menu bar item entirely while recording so no placeholder space remains.
    private var menuBarIsInserted: Binding<Bool> {
        Binding(
            get: { menuBarInserted && appState.appStatus != .recording },
            set: { newValue in
                // Only persist user-driven removal from the menu bar. When we hide
                // for recording, macOS may write `false` back through this binding;
                // ignoring that keeps menuBarInserted true so the icon reappears.
                if appState.appStatus != .recording {
                    menuBarInserted = newValue
                }
            }
        )
    }

    var body: some Scene {
        // Menu bar presence — the primary UI for VocaMac
        MenuBarExtra(isInserted: menuBarIsInserted) {
            MenuBarView(settingsManager: settingsManager)
                .environmentObject(appState)
        } label: {
            MenuBarIcon(appStatus: appState.appStatus)
                .onAppear {
                    // Trigger startup from the SwiftUI lifecycle so it only runs
                    // on the AppState instance that SwiftUI actually retains.
                    // Previously, startup ran in AppState.init() which caused
                    // double initialization (and double event taps) because
                    // SwiftUI may instantiate the App struct more than once.
                    appState.triggerStartupIfNeeded()
                }
        }
        .menuBarExtraStyle(.window)
        .onChange(of: appState.appStatus) { newStatus in
            // Recover if an older build cleared menuBarInserted while hidden for recording.
            if wasRecordingForMenuBar, newStatus != .recording, !menuBarInserted {
                menuBarInserted = true
            }
            wasRecordingForMenuBar = (newStatus == .recording)
        }
    }

    @MainActor init() {
        // Ensure only one instance of VocaMac is running
        Self.ensureSingleInstance()

        // For .app bundles, Dock hiding is handled by LSUIElement=true in Info.plist.
        // For direct binary execution, we set it programmatically.
        DispatchQueue.main.async {
            NSApp?.setActivationPolicy(.accessory)
        }

        // Listen for "Show Setup Wizard" requests from Settings / Menu Bar
        NotificationCenter.default.addObserver(
            forName: .showOnboarding,
            object: nil,
            queue: .main
        ) { [self] _ in
            Task { @MainActor [self] in
                self.onboardingManager.open(appState: self.appState, force: true)
            }
        }

        // Show onboarding on first launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            if !self.appState.hasCompletedOnboarding {
                self.onboardingManager.open(appState: self.appState)
            }
        }
    }

    /// Terminate any other running instances of VocaMac
    private static func ensureSingleInstance() {
        let currentPID = ProcessInfo.processInfo.processIdentifier
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.vocamac.app")

        for app in runningApps where app.processIdentifier != currentPID {
            VocaLogger.info(.general, "Terminating previous instance (PID \(app.processIdentifier))")
            app.terminate()
        }

        // Also kill by process name for direct binary execution (no bundle ID)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
        task.arguments = ["-f", "VocaMac"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let pids = output.split(separator: "\n").compactMap { Int32($0) }
                for pid in pids where pid != currentPID {
                    VocaLogger.info(.general, "Killing previous VocaMac process (PID \(pid))")
                    kill(pid, SIGTERM)
                }
            }
        } catch {
            // pgrep not found or failed — not critical
        }
    }
}

// MARK: - Menu Bar Icon

/// Renders a mic icon in the menu bar with color changes based on app status.
///
/// Uses NSImage to create properly tinted menu bar icons because MenuBarExtra's
/// label treats SwiftUI `.foregroundStyle()` colors as template images, stripping
/// color. By setting `isTemplate = false` for non-idle states, macOS renders
/// the actual color in the menu bar.
///
/// States:
///   • idle / recording → system template mic (recording hides MenuBarExtra entirely)
///   • processing       → purple spinner (non-template, colored)
///   • error            → yellow warning (non-template, colored)
struct MenuBarIcon: View {
    let appStatus: AppStatus

    var body: some View {
        Image(nsImage: makeMenuBarIcon())
    }

    private func makeMenuBarIcon() -> NSImage {
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)

        guard let baseImage = NSImage(systemSymbolName: iconName, accessibilityDescription: "VocaMac")?
            .withSymbolConfiguration(config) else {
            let fallback = NSImage(systemSymbolName: "mic", accessibilityDescription: "VocaMac") ?? NSImage()
            fallback.isTemplate = usesTemplateIcon
            return fallback
        }

        // Idle / recording: system template icon (recording never tints red; item is hidden).
        if usesTemplateIcon {
            baseImage.isTemplate = true
            return baseImage
        }

        // Active states: tint with status color
        let tintColor = nsColor
        let size = baseImage.size

        let tinted = NSImage(size: size, flipped: false) { rect in
            baseImage.draw(in: rect)
            tintColor.set()
            rect.fill(using: .sourceAtop)
            return true
        }
        tinted.isTemplate = false
        return tinted
    }

    private var usesTemplateIcon: Bool {
        appStatus == .idle || appStatus == .recording
    }

    private var iconName: String {
        switch appStatus {
        case .idle, .recording:
            return "mic.fill"
        case .processing:
            return "ellipsis.circle"
        case .error:
            return "exclamationmark.triangle"
        }
    }

    private var nsColor: NSColor {
        switch appStatus {
        case .idle, .recording:
            return .labelColor
        case .processing:
            return NSColor(red: 0.749, green: 0.353, blue: 0.949, alpha: 1.0) // #BF5AF2
        case .error:
            return .systemYellow
        }
    }
}
