// AppStateRecordingTests.swift
// VocaMac
//
// Tests for AppState recording flow and state transitions.

import XCTest
@testable import VocaMac

// MARK: - AppState Recording State Transition Tests

@MainActor
final class AppStateRecordingTests: XCTestCase {

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "vocamac.simplifiedChineseEnabled")
        UserDefaults.standard.removeObject(forKey: "vocamac.punctuationEnabled")
        super.tearDown()
    }

    func testInitialState() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertEqual(appState.appStatus, .idle, "App should start in idle state")
        XCTAssertFalse(appState.isRecording, "Should not be recording initially")
        XCTAssertNil(appState.errorMessage, "No error message initially")
        XCTAssertEqual(appState.audioLevel, 0.0, "Audio level should be zero")
    }

    func testStartRecordingWithDeniedMicPermission() async {
        let (appState, mocks) = AppState.makeTestState()
        mocks.permissionManager.micPermission = .denied

        await appState.startRecording()

        XCTAssertEqual(appState.appStatus, .error,
                      "Should transition to error when mic permission is denied")
        XCTAssertNotNil(appState.errorMessage,
                       "Should set an error message about microphone permission")
        XCTAssertTrue(appState.errorMessage?.contains("麦克风") == true,
                     "Error message should mention microphone")
    }

    func testStartRecordingInProcessingStateForceRecovers() async {
        let (appState, _) = AppState.makeTestState()
        appState.appStatus = .processing

        await appState.startRecording()

        XCTAssertEqual(appState.appStatus, .idle,
                      "startRecording in processing state should force recover to idle")
    }

    func testStopRecordingWhenNotRecording() async {
        let (appState, _) = AppState.makeTestState()

        await appState.stopRecordingAndTranscribe()

        XCTAssertEqual(appState.appStatus, .idle,
                      "Should remain idle when stopping without recording")
        XCTAssertFalse(appState.isRecording)
    }

    func testStopRecordingResetsAudioLevel() async {
        let (appState, mocks) = AppState.makeTestState()
        appState.isRecording = true
        appState.appStatus = .recording
        appState.audioLevel = 0.75

        await appState.stopRecordingAndTranscribe()

        XCTAssertEqual(appState.audioLevel, 0.0,
                      "Audio level should be reset to 0 after stopping")
        XCTAssertFalse(appState.isRecording,
                      "isRecording should be false after stopping")
        XCTAssertEqual(mocks.soundManager.stopSoundCallCount, 1,
                      "Stop sound should be played once")
    }

    func testStopRecordingWithEmptyAudioReturnsToIdle() async {
        let (appState, _) = AppState.makeTestState()
        appState.isRecording = true
        appState.appStatus = .recording

        await appState.stopRecordingAndTranscribe()

        XCTAssertEqual(appState.appStatus, .idle,
                      "Should return to idle when audio data is empty")
    }

    func testSelectedModelSizeDefault() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertEqual(appState.selectedModelSize, ModelSize.tiny.rawValue,
                      "Default model size should be tiny")
    }

    func testPreserveClipboardDefault() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertTrue(appState.preserveClipboard,
                     "preserveClipboard should default to true")
    }

    func testSoundEffectsEnabledDefault() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertTrue(appState.soundEffectsEnabled,
                     "Sound effects should be enabled by default")
    }

    func testSimplifiedChineseEnabledByDefault() {
        UserDefaults.standard.removeObject(forKey: "vocamac.simplifiedChineseEnabled")
        let (appState, _) = AppState.makeTestState()

        XCTAssertTrue(appState.simplifiedChineseEnabled,
                      "Simplified Chinese normalization should be enabled by default")
    }

    func testPunctuationEnabledByDefault() {
        UserDefaults.standard.removeObject(forKey: "vocamac.punctuationEnabled")
        let (appState, _) = AppState.makeTestState()

        XCTAssertTrue(appState.punctuationEnabled,
                      "Punctuation restoration should be enabled by default")
    }

    @MainActor
    func testStopRecordingConvertsTraditionalChineseWhenEnabled() async {
        let (appState, mocks) = AppState.makeTestState()
        mocks.audioEngine.stopRecordingResult = [0.1, 0.2]
        mocks.whisperService.mockTranscriptionResult = VocaTranscription(
            text: " 臺灣  ",
            duration: 0.5,
            detectedLanguage: "zh",
            audioLengthSeconds: 0.1,
            modelUsed: .tiny
        )
        appState.simplifiedChineseEnabled = true
        appState.isRecording = true
        appState.appStatus = .recording

        await appState.stopRecordingAndTranscribe()

        XCTAssertEqual(mocks.textInjector.lastInjectedText, "台湾")
        XCTAssertEqual(appState.lastTranscription?.text, "台湾")
    }

    @MainActor
    func testStopRecordingPreservesTraditionalChineseWhenDisabled() async {
        let (appState, mocks) = AppState.makeTestState()
        mocks.audioEngine.stopRecordingResult = [0.1, 0.2]
        mocks.whisperService.mockTranscriptionResult = VocaTranscription(
            text: "臺灣",
            duration: 0.5,
            detectedLanguage: "zh",
            audioLengthSeconds: 0.1,
            modelUsed: .tiny
        )
        appState.simplifiedChineseEnabled = false
        appState.isRecording = true
        appState.appStatus = .recording

        await appState.stopRecordingAndTranscribe()

        XCTAssertEqual(mocks.textInjector.lastInjectedText, "臺灣")
        XCTAssertEqual(appState.lastTranscription?.text, "臺灣")
    }

    @MainActor
    func testStopRecordingAppliesPunctuationWhenEnabled() async {
        let (appState, mocks) = AppState.makeTestState()
        mocks.audioEngine.stopRecordingResult = [0.1, 0.2]
        mocks.whisperService.mockTranscriptionResult = VocaTranscription(
            text: "你好世界",
            duration: 0.5,
            detectedLanguage: "zh",
            audioLengthSeconds: 0.1,
            modelUsed: .tiny
        )
        mocks.punctuationEngine.punctuatedText = "你好，世界。"
        appState.punctuationEnabled = true
        appState.isRecording = true
        appState.appStatus = .recording

        await appState.stopRecordingAndTranscribe()

        XCTAssertEqual(mocks.punctuationEngine.addPunctuationCallCount, 1)
        XCTAssertEqual(mocks.textInjector.lastInjectedText, "你好，世界。")
    }

    func testSelectedLanguageDefault() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertEqual(appState.selectedLanguage, "zh",
                      "Default language should be 'zh' (Chinese)")
    }

    func testActivationModeDefault() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertEqual(appState.activationMode, .pushToTalk,
                      "Default activation mode should be push-to-talk")
    }

    func testHotKeyCodeDefault() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertEqual(appState.hotKeyCode, 63,
                      "Default hotkey should be Fn (keyCode 63)")
    }

    func testDoubleTapThresholdDefault() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertEqual(appState.doubleTapThreshold, 0.4,
                      "Default double-tap threshold should be 0.4 seconds")
    }

    func testMaxRecordingDurationDefault() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertEqual(appState.maxRecordingDuration, 60,
                      "Default max recording duration should be 60 seconds")
    }

    func testAvailableModelsPopulated() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertFalse(appState.availableModels.isEmpty,
                      "Available models should be populated on init")
        XCTAssertEqual(appState.availableModels.count, ModelSize.allCases.count,
                      "Should have one entry per ModelSize")
    }

    func testSystemCapabilitiesDetected() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertNotNil(appState.systemCapabilities,
                       "System capabilities should be detected on init")
    }

    func testDeviceRecommendedModelSet() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertNotNil(appState.deviceRecommendedModel,
                       "Device recommended model should be set on init")
    }

    func testPermissionManagerIntegration() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertNotNil(appState.permissionManager,
                       "PermissionManager should be initialized")

        let mic = appState.micPermission
        XCTAssertEqual(mic, appState.permissionManager.micPermission,
                      "micPermission should delegate to PermissionManager")
    }

    func testTriggerStartupIdempotent() {
        // Reset the global flag so this test is self-contained regardless of
        // test execution order.
        AppState.hasStartedGlobally = false
        defer { AppState.hasStartedGlobally = false }

        let (appState, _) = AppState.makeTestState()

        appState.triggerStartupIfNeeded()
        appState.triggerStartupIfNeeded()
        appState.triggerStartupIfNeeded()
    }
}

// MARK: - AppState Error Recovery Tests

@MainActor
final class AppStateErrorRecoveryTests: XCTestCase {

    func testErrorStateCanBeCleared() {
        let (appState, _) = AppState.makeTestState()
        appState.appStatus = .error
        appState.errorMessage = "Test error"

        appState.appStatus = .idle
        appState.errorMessage = nil

        XCTAssertEqual(appState.appStatus, .idle)
        XCTAssertNil(appState.errorMessage)
    }

    func testStartRecordingWhileRecordingTriggersRecovery() async {
        let (appState, mocks) = AppState.makeTestState()
        appState.isRecording = true
        appState.appStatus = .recording

        await appState.startRecording()

        XCTAssertFalse(appState.isRecording,
                      "Recovery path should stop recording")
        XCTAssertEqual(mocks.soundManager.stopSoundCallCount, 1,
                      "Stop sound should play during recovery")
    }
}

// MARK: - AppState Force Recovery Tests

final class AppStateForceRecoveryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "vocamac.hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "vocamac.launchAtLogin")
    }

    @MainActor
    func testForceRecoveryResetsToIdle() {
        let (appState, mocks) = AppState.makeTestState()

        appState.appStatus = .recording
        appState.isRecording = true
        appState.audioLevel = 0.5

        appState.forceRecovery()

        XCTAssertEqual(appState.appStatus, .idle,
            "appStatus should be idle after force recovery")
        XCTAssertFalse(appState.isRecording,
            "isRecording should be false after force recovery")
        XCTAssertEqual(appState.audioLevel, 0.0,
            "audioLevel should be 0 after force recovery")
        XCTAssertNil(appState.errorMessage,
            "errorMessage should be nil after force recovery")
        XCTAssertEqual(mocks.audioEngine.forceResetCallCount, 1,
            "forceReset should be called on audio engine")
    }

    @MainActor
    func testForceRecoveryFromErrorState() {
        let (appState, _) = AppState.makeTestState()

        appState.appStatus = .error
        appState.errorMessage = "Something went wrong"

        appState.forceRecovery()

        XCTAssertEqual(appState.appStatus, .idle,
            "appStatus should be idle after force recovery from error")
        XCTAssertNil(appState.errorMessage,
            "errorMessage should be cleared after force recovery")
    }

    @MainActor
    func testForceRecoveryFromProcessingState() {
        let (appState, _) = AppState.makeTestState()

        appState.appStatus = .processing
        appState.isRecording = false

        appState.forceRecovery()

        XCTAssertEqual(appState.appStatus, .idle,
            "appStatus should be idle after force recovery from processing")
    }

    @MainActor
    func testForceRecoveryWhenAlreadyIdle() {
        let (appState, _) = AppState.makeTestState()

        XCTAssertEqual(appState.appStatus, .idle)

        appState.forceRecovery()

        XCTAssertEqual(appState.appStatus, .idle,
            "appStatus should remain idle")
        XCTAssertFalse(appState.isRecording)
        XCTAssertNil(appState.errorMessage)
    }

    @MainActor
    func testForceRecoveryMultipleTimes() {
        let (appState, _) = AppState.makeTestState()
        appState.appStatus = .recording
        appState.isRecording = true

        appState.forceRecovery()
        appState.forceRecovery()
        appState.forceRecovery()

        XCTAssertEqual(appState.appStatus, .idle)
        XCTAssertFalse(appState.isRecording)
    }
}

// MARK: - AppState Recording State Guard Tests

final class AppStateRecordingGuardTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "vocamac.hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "vocamac.launchAtLogin")
    }

    @MainActor
    func testStartRecordingInErrorStateForceRecovers() async {
        let (appState, _) = AppState.makeTestState()
        appState.appStatus = .error
        appState.errorMessage = "Previous error"

        await appState.startRecording()

        XCTAssertEqual(appState.appStatus, .idle,
            "startRecording in error state should force recover to idle")
        XCTAssertNil(appState.errorMessage,
            "Error message should be cleared after force recovery")
    }

    @MainActor
    func testStartRecordingInProcessingStateForceRecovers() async {
        let (appState, _) = AppState.makeTestState()
        appState.appStatus = .processing

        await appState.startRecording()

        XCTAssertEqual(appState.appStatus, .idle,
            "startRecording in processing state should force recover to idle")
    }

    @MainActor
    func testStopRecordingWhenNotRecordingIsNoop() async {
        let (appState, _) = AppState.makeTestState()
        XCTAssertEqual(appState.appStatus, .idle)
        XCTAssertFalse(appState.isRecording)

        await appState.stopRecordingAndTranscribe()

        XCTAssertEqual(appState.appStatus, .idle)
        XCTAssertFalse(appState.isRecording)
    }

    @MainActor
    func testInitialStateIsIdle() {
        let (appState, _) = AppState.makeTestState()
        XCTAssertEqual(appState.appStatus, .idle)
        XCTAssertFalse(appState.isRecording)
        XCTAssertEqual(appState.audioLevel, 0.0)
        XCTAssertNil(appState.errorMessage)
    }
}
