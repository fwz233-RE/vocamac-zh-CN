// OnboardingView.swift
// VocaMac
//
// Multi-step onboarding wizard for first-time users.
// Guides users through welcome, permissions, model selection, hotkey setup, and testing.

import SwiftUI

// MARK: - Onboarding Step Enum

/// Represents the current step in the onboarding flow
enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome = 0
    case permissions = 1
    case hotkeyConfig = 2
    case quickTest = 3
    case complete = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .welcome: return "欢迎使用 VocaMac"
        case .permissions: return "授予权限"
        case .hotkeyConfig: return "配置快捷键"
        case .quickTest: return "快速测试"
        case .complete: return "全部完成！"
        }
    }

    var stepNumber: String {
        "第 \(rawValue + 1) 步，共 \(OnboardingStep.allCases.count) 步"
    }
}

// MARK: - OnboardingView

/// Main onboarding wizard container
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep: OnboardingStep = .welcome

    var body: some View {
        ZStack {
            // Background
            Color(nsColor: .controlBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Step indicator
                HStack {
                    Text(currentStep.stepNumber)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(OnboardingStep.allCases, id: \.self) { step in
                            Circle()
                                .fill(step.rawValue <= currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding()
                .borderBottom()

                // Step content (scrollable to handle varying content heights)
                ScrollView {
                    Group {
                        switch currentStep {
                        case .welcome:
                            WelcomeStep()
                        case .permissions:
                            PermissionsStep()
                        case .hotkeyConfig:
                            HotkeyConfigStep()
                        case .quickTest:
                            QuickTestStep()
                        case .complete:
                            CompleteStep()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                // Navigation buttons
                HStack(spacing: 12) {
                    if currentStep == .welcome {
                        Button(action: skipOnboarding) {
                            Text("跳过设置")
                                .font(.body)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .foregroundStyle(.primary)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .help("跳过设置且不再显示。可从菜单栏 → 设置向导重新运行。")
                    } else if currentStep != .complete {
                        Button(action: skipOnboarding) {
                            Text("跳过")
                                .font(.body)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        .help("跳过设置且不再显示。")
                    }
                    if currentStep != .welcome {
                        Button(action: goToPreviousStep) {
                            Text("上一步")
                                .font(.body)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .foregroundStyle(.primary)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut(.cancelAction)
                    }

                    Spacer()

                    if currentStep != .complete {
                        Button(action: goToNextStep) {
                            Text(currentStep == .quickTest ? "完成" : "继续")
                                .font(.body)
                                .fontWeight(.medium)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut(.defaultAction)
                    } else {
                        Button(action: completeOnboarding) {
                            Text("开始使用 VocaMac")
                                .font(.body)
                                .fontWeight(.medium)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .padding()
            }
        }
        .frame(width: 600, height: 550)
    }

    // MARK: - Navigation

    private func goToNextStep() {
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = nextStep
            }
        }
    }

    private func goToPreviousStep() {
        if let prevStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = prevStep
            }
        }
    }

    private func skipOnboarding() {
        appState.completeOnboarding()
    }

    private func completeOnboarding() {
        appState.completeOnboarding()
    }
}

// MARK: - Step 1: Welcome

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // App icon
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            // App name and tagline
            VStack(spacing: 8) {
                Text("VocaMac")
                    .font(.system(size: 40, weight: .bold))

                Text("你的声音，你的 Mac，你的隐私")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // Description
            VStack(alignment: .leading, spacing: 12) {
                Label("直接在任何应用中听写", systemImage: "doc.text")
                Label("所有处理都在你的 Mac 上完成", systemImage: "lock.fill")
                Label("无需联网，数据不会离开你的设备", systemImage: "network.slash")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Spacer()

            Text("本向导将在几分钟内完成 VocaMac 的设置。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Step 2: Permissions

struct PermissionsStep: View {
    @EnvironmentObject var appState: AppState

    private var allPermissionsGranted: Bool {
        appState.micPermission == .granted &&
        appState.accessibilityPermission == .granted &&
        appState.inputMonitoringPermission == .granted
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("VocaMac 需要以下权限才能正常工作。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            VStack(spacing: 12) {
                OnboardingPermissionRow(
                    icon: "mic.fill",
                    name: "麦克风",
                    description: "录制音频用于转写",
                    status: appState.micPermission,
                    action: { appState.requestMicrophonePermission() }
                )

                OnboardingPermissionRow(
                    icon: "hand.raised.fill",
                    name: "辅助功能",
                    description: "监听快捷键以激活录音",
                    status: appState.accessibilityPermission,
                    action: { appState.requestAccessibilityPermission() }
                )

                OnboardingPermissionRow(
                    icon: "keyboard.fill",
                    name: "输入监控",
                    description: "检测键盘和鼠标输入以激活录音",
                    status: appState.inputMonitoringPermission,
                    action: { appState.requestInputMonitoringPermission() }
                )
            }
            .padding()

            Spacer()

            if !allPermissionsGranted {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    Text("部分权限尚未授予。在全部授权之前，VocaMac 可能无法正常工作。你也可以稍后在设置 → 调试中配置。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.yellow.opacity(0.05))
                .cornerRadius(8)
                .padding(.horizontal)
            }

            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Text("你可以在系统设置 > 隐私与安全性中授予这些权限。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Onboarding Permission Row

struct OnboardingPermissionRow: View {
    let icon: String
    let name: String
    let description: String
    let status: PermissionStatus
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .frame(width: 32)
                .foregroundStyle(statusColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                if status == .granted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)
                } else {
                    Button(action: action) {
                        Text(status == .notDetermined ? "授权" : "打开设置")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }

    private var statusColor: Color {
        switch status {
        case .granted: return .green
        case .denied: return .red
        case .notDetermined: return .gray
        }
    }
}

// MARK: - Step 3: Model Selection

struct ModelSelectionStep: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            Text("根据你的设备和需求选择模型。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            if let recommended = appState.deviceRecommendedModel,
               let recommendedSize = ModelSize.allCases.first(where: { size in
                   let prefix = "openai_whisper-\(size.rawValue)"
                   return recommended == prefix || recommended.hasPrefix(prefix + "-")
               }) {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("推荐使用：**\(recommendedSize.displayName)**")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
            }

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(appState.availableModels) { modelInfo in
                        ModelSelectionCard(
                            modelInfo: modelInfo,
                            isRecommended: {
                                guard let recommended = appState.deviceRecommendedModel else { return false }
                                let prefix = "openai_whisper-\(modelInfo.size.rawValue)"
                                return recommended == prefix || recommended.hasPrefix(prefix + "-")
                            }(),
                            onSelect: {
                                Task { @MainActor in
                                    await appState.loadModel(modelInfo.size)
                                }
                            },
                            onDownload: {
                                Task { @MainActor in
                                    await appState.downloadModel(modelInfo.size)
                                }
                            }
                        )
                    }
                }
                .padding()
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Model Selection Card

struct ModelSelectionCard: View {
    let modelInfo: WhisperModelInfo
    let isRecommended: Bool
    let onSelect: () -> Void
    let onDownload: () -> Void
    @State private var showForceDownloadAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(modelInfo.size.displayName)
                            .font(.body)
                            .fontWeight(.semibold)
                        if isRecommended {
                            Label("推荐", systemImage: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(4)
                        }
                        Spacer()
                    }

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("下载")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(modelInfo.size.fileSizeDescription)
                                .font(.caption)
                                .fontWeight(.medium)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("运行内存")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(modelInfo.size.ramRequiredDescription)
                                .font(.caption)
                                .fontWeight(.medium)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("速度")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(modelInfo.size.relativeSpeed)x")
                                .font(.caption)
                                .fontWeight(.medium)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("质量")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(modelInfo.size.qualityDescription)
                                .font(.caption)
                                .fontWeight(.medium)
                        }

                        Spacer()
                    }
                }

                Spacer()
            }

            HStack(spacing: 12) {
                if let progress = modelInfo.downloadProgress {
                    VStack(alignment: .leading, spacing: 4) {
                        ProgressView(value: progress)
                        Text("\(Int(progress * 100))%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else if modelInfo.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text(modelInfo.loadingStatus)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else if modelInfo.isDownloaded {
                    if modelInfo.isActive {
                        Label("使用中", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    } else {
                        Button(action: onSelect) {
                            Text("使用此模型")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                } else if !modelInfo.isSupported {
                    Button {
                        showForceDownloadAlert = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                            Text("仍要尝试")
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .foregroundStyle(.secondary)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: onDownload) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.circle")
                            Text("下载")
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .foregroundStyle(.primary)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isRecommended ? Color.orange : Color.clear, lineWidth: 1.5)
        )
        .alert("使用实验性模型？", isPresented: $showForceDownloadAlert) {
            Button("取消", role: .cancel) {}
            Button("仍要下载", role: .destructive) {
                onDownload()
            }
        } message: {
            Text("WhisperKit 尚未验证此模型在你的芯片系列上的兼容性。它很可能可以运行，但可能比优化模型更慢。")
        }
    }
}

// MARK: - Step 4: Hotkey Configuration

struct HotkeyConfigStep: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            Text("选择如何激活 VocaMac。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            VStack(spacing: 16) {
                // Activation Mode
                VStack(alignment: .leading, spacing: 8) {
                    Text("激活方式")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Picker("模式", selection: $appState.activationMode) {
                        ForEach(ActivationMode.allCases) { mode in
                            VStack(alignment: .leading) {
                                Text(mode.displayName)
                            }
                            .tag(mode)
                        }
                    }
                    .pickerStyle(.radioGroup)

                    Text(appState.activationMode.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Hotkey Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("快捷键")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Picker("按键", selection: $appState.hotKeyCode) {
                        ForEach(KeyCodeReference.commonHotKeys, id: \.keyCode) { hotKey in
                            Text(hotKey.name).tag(hotKey.keyCode)
                        }
                    }

                    Text("按下此键开始录音。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if appState.activationMode == .doubleTapToggle {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("双击速度")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        HStack {
                            Slider(
                                value: $appState.doubleTapThreshold,
                                in: 0.2...0.8,
                                step: 0.05
                            )
                            Text("\(String(format: "%.2f", appState.doubleTapThreshold))s")
                                .monospacedDigit()
                                .frame(width: 40)
                        }

                        Text("双击按键的时间间隔要求。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Step 5: Quick Test

struct QuickTestStep: View {
    @EnvironmentObject var appState: AppState
    @State private var isRecording = false
    @State private var testResult: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("让我们通过一次快速录音来测试你的设置。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 16) {
                // Recording button
                Button(action: toggleRecording) {
                    VStack(spacing: 8) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(isRecording ? .red : .blue)

                        Text(isRecording ? "录音中…" : "点击开始录音")
                            .font(.body)
                            .fontWeight(.semibold)

                        if isRecording {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 8)
                                    .scaleEffect(1.2)

                                Text("正在录制音频…")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .disabled(appState.appStatus == .processing)

                // Test result display
                if let result = testResult {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("转写结果")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }

                        Text(result)
                            .font(.subheadline)
                            .lineLimit(4)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                    }
                } else if appState.appStatus == .processing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8, anchor: .center)
                        Text("转写中…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Text("试试说一个短句，比如「你好世界」。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
    }

    private func toggleRecording() {
        if isRecording {
            Task { @MainActor in
                await appState.stopRecordingAndTranscribe()
                isRecording = false
            }
        } else {
            Task { @MainActor in
                await appState.startRecording()
                isRecording = true
            }
        }
    }
}

// MARK: - Step 6: Complete

struct CompleteStep: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            // Heading
            VStack(spacing: 8) {
                Text("一切就绪！")
                    .font(.title)
                    .fontWeight(.bold)

                Text("VocaMac 已准备就绪")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // Summary
            VStack(alignment: .leading, spacing: 12) {
                SummaryItem(icon: "mic.fill", text: "麦克风权限已启用")
                if appState.accessibilityPermission == .granted {
                    SummaryItem(icon: "hand.raised.fill", text: "辅助功能权限已授予")
                }
                if appState.inputMonitoringPermission == .granted {
                    SummaryItem(icon: "keyboard.fill", text: "输入监控已启用")
                }
                SummaryItem(icon: "keyboard", text: "快捷键：\(KeyCodeReference.displayName(for: appState.hotKeyCode))")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(8)

            // Launch at Login option
            Toggle(isOn: Binding(
                get: { appState.launchAtLogin },
                set: { appState.setLaunchAtLogin($0) }
            )) {
                HStack(spacing: 10) {
                    Image(systemName: "sunrise.fill")
                        .foregroundStyle(.orange)
                        .frame(width: 20)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("登录时启动")
                            .font(.subheadline)
                        Text("登录 Mac 时自动启动 VocaMac")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .toggleStyle(.switch)
            .controlSize(.small)
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)

            Spacer()

            Text("你可以随时从 VocaMac 菜单中调整设置。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }
}

struct SummaryItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.green)
                .frame(width: 20)

            Text(text)
                .font(.subheadline)

            Spacer()
        }
    }
}

// MARK: - Helpers

extension View {
    func borderBottom() -> some View {
        VStack(spacing: 0) {
            self
            Divider()
        }
    }
}

#if DEBUG
#Preview {
    OnboardingView()
        .environmentObject(AppState.production())
}
#endif
