// SettingsView.swift
// VocaMac
//
// Settings window for VocaMac configuration.
// Organized into tabs: General, Models, Audio, Debug, About.

import SwiftUI

extension Notification.Name {
    static let showOnboarding = Notification.Name("com.vocamac.showOnboarding")
}

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem {
                    Label("通用", systemImage: "gear")
                }

            ModelSettingsTab()
                .tabItem {
                    Label("模型", systemImage: "brain")
                }

            AudioSettingsTab()
                .tabItem {
                    Label("音频", systemImage: "waveform")
                }

            DebugTab()
                .tabItem {
                    Label("调试", systemImage: "ladybug")
                }

            AboutTab()
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
        }
        .frame(width: 560, height: 520)
    }
}

// MARK: - General Settings

struct GeneralSettingsTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Form {
            // Activation Mode
            Section("激活方式") {
                Picker("模式", selection: $appState.activationMode) {
                    ForEach(ActivationMode.allCases) { mode in
                        VStack(alignment: .leading) {
                            Text(mode.displayName)
                        }
                        .tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)
                .onChange(of: appState.activationMode) { newMode in
                    appState.hotKeyManager.updateConfiguration(mode: newMode)
                }

                Text(appState.activationMode.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Hotkey
            Section("快捷键") {
                Picker("激活按键", selection: $appState.hotKeyCode) {
                    ForEach(KeyCodeReference.commonHotKeys, id: \.keyCode) { hotKey in
                        Text(hotKey.name).tag(hotKey.keyCode)
                    }
                }
                .onChange(of: appState.hotKeyCode) { newCode in
                    appState.hotKeyManager.updateConfiguration(keyCode: newCode)
                }

                if appState.activationMode == .doubleTapToggle {
                    HStack {
                        Text("双击速度")
                        Slider(
                            value: $appState.doubleTapThreshold,
                            in: 0.2...0.8,
                            step: 0.05
                        )
                        Text("\(String(format: "%.2f", appState.doubleTapThreshold))s")
                            .monospacedDigit()
                            .frame(width: 40)
                    }
                    .onChange(of: appState.doubleTapThreshold) { newVal in
                        appState.hotKeyManager.updateConfiguration(doubleTapThreshold: newVal)
                    }

                    Text("数值越小，双击间隔要求越短；数值越大，越宽松。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Language
            Section("转写语言") {
                Picker("语言", selection: $appState.selectedLanguage) {
                    Text("自动检测").tag("auto")
                    Divider()
                    Group {
                        Text("英语").tag("en")
                        Text("西班牙语").tag("es")
                        Text("法语").tag("fr")
                        Text("德语").tag("de")
                        Text("意大利语").tag("it")
                        Text("葡萄牙语").tag("pt")
                        Text("荷兰语").tag("nl")
                    }
                    Divider()
                    Group {
                        Text("中文").tag("zh")
                        Text("日语").tag("ja")
                        Text("韩语").tag("ko")
                        Text("印地语").tag("hi")
                        Text("阿拉伯语").tag("ar")
                        Text("俄语").tag("ru")
                        Text("土耳其语").tag("tr")
                        Text("波兰语").tag("pl")
                        Text("瑞典语").tag("sv")
                        Text("乌克兰语").tag("uk")
                    }
                }

                Text("自动检测适用于大多数场景。指定语言可提高识别准确度。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("文本") {
                Toggle("简体保持", isOn: $appState.simplifiedChineseEnabled)

                Text(appState.simplifiedChineseEnabled
                    ? "转写结果中的繁体中文将自动转为简体后再插入。"
                    : "转写结果按识别原文插入，不进行繁简转换。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("行为") {
                Toggle("登录时启动", isOn: Binding(
                    get: { appState.launchAtLogin },
                    set: { appState.setLaunchAtLogin($0) }
                ))

                Toggle("注入文字后保留剪贴板内容", isOn: $appState.preserveClipboard)

                Text("启用后，注入文字后会恢复你原来的剪贴板内容。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

        }
        .formStyle(.grouped)
    }
}

// MARK: - Permission Row

struct PermissionRow: View {
    let name: String
    let icon: String
    let status: PermissionStatus
    let action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundStyle(statusColor)
                .frame(width: 16)
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 16)
            Text(name)
            Spacer()
            switch status {
            case .granted:
                Text("已授权")
                    .font(.caption)
                    .foregroundStyle(.green)
            case .notDetermined:
                Button("授权") { action() }
                    .controlSize(.small)
            case .denied:
                Button("打开设置") { action() }
                    .controlSize(.small)
            }
        }
    }

    private var statusIcon: String {
        switch status {
        case .granted: return "checkmark.circle.fill"
        case .notDetermined: return "questionmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch status {
        case .granted: return .green
        case .notDetermined: return .orange
        case .denied: return .red
        }
    }
}

// MARK: - Model Settings

struct ModelSettingsTab: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var processMonitor = ProcessMonitor()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // System info
                if let capabilities = appState.systemCapabilities {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("系统信息", systemImage: "cpu")
                                .font(.headline)
                                .padding(.bottom, 4)

                            HStack(spacing: 24) {
                                SystemInfoPill(icon: "cpu", label: "CPU", value: capabilities.processorName)
                                SystemInfoPill(icon: "memorychip", label: "RAM", value: "\(capabilities.physicalMemoryGB) GB")
                                SystemInfoPill(icon: "bolt.fill", label: "Metal", value: capabilities.supportsMetalAcceleration ? "是" : "否")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                        }
                        .padding(4)
                    }
                }

                // Resource usage
                GroupBox {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("资源占用", systemImage: "gauge.with.dots.needle.bottom.50percent")
                            .font(.headline)
                            .padding(.bottom, 4)

                        HStack(spacing: 24) {
                            SystemInfoPill(
                                icon: "cpu",
                                label: "CPU",
                                value: String(format: "%.1f%%", processMonitor.cpuUsage)
                            )
                            SystemInfoPill(
                                icon: "memorychip",
                                label: "内存",
                                value: processMonitor.memoryMB >= 1024
                                    ? String(format: "%.1f GB", processMonitor.memoryMB / 1024)
                                    : String(format: "%.0f MB", processMonitor.memoryMB)
                            )
                            SystemInfoPill(
                                icon: "chart.line.uptrend.xyaxis",
                                label: "峰值",
                                value: processMonitor.memoryPeakMB >= 1024
                                    ? String(format: "%.1f GB", processMonitor.memoryPeakMB / 1024)
                                    : String(format: "%.0f MB", processMonitor.memoryPeakMB)
                            )
                            SystemInfoPill(
                                icon: "arrow.triangle.branch",
                                label: "线程",
                                value: "\(processMonitor.threadCount)"
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(4)
                }

                // Currently active model
                if let current = appState.currentModel {
                    GroupBox {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                                .font(.title3)
                            VStack(alignment: .leading) {
                                Text("当前模型：\(current.size.displayName)")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                Text("\(current.size.qualityDescription) 质量 • \(current.size.fileSizeDescription)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(4)
                    }
                }

                // Model list
                GroupBox {
                    VStack(alignment: .leading, spacing: 0) {
                        Label("可用模型", systemImage: "list.bullet")
                            .font(.headline)
                            .padding(.bottom, 8)
                            .padding(.horizontal, 4)

                        ForEach(appState.availableModels) { model in
                            ModelRow(model: model, appState: appState)

                            if model.size != ModelSize.allCases.last {
                                Divider()
                                    .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding(4)
                }

                // Info text
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                    Text("模型从 HuggingFace 下载并缓存在本地。更大的模型效果更好，但速度更慢、占用内存更多。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let recommended = appState.deviceRecommendedModel,
                   let recommendedSize = ModelSize.allCases.first(where: { size in
                       let prefix = "openai_whisper-\(size.rawValue)"
                       return recommended == prefix || recommended.hasPrefix(prefix + "-")
                   }) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("推荐用于你的设备：**\(recommendedSize.displayName)**")
                                .font(.callout)
                            Text("基于 WhisperKit 针对你芯片的优化版本，而非根据内存大小推荐。")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                HStack {
                    Image(systemName: "internaldrive")
                        .foregroundStyle(.secondary)
                    Text("模型存储：\(appState.modelManager.diskUsageDescription())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }
}

struct SystemInfoPill: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ModelRow: View {
    let model: WhisperModelInfo
    @ObservedObject var appState: AppState
    @State private var showForceDownloadAlert = false

    var body: some View {
        HStack {
            // Status icon
            Image(systemName: model.statusIconName)
                .foregroundStyle(model.isActive ? .green : .secondary)
                .frame(width: 20)

            // Model info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(model.size.displayName)
                        .font(.callout)
                        .fontWeight(model.isActive ? .semibold : .regular)

                    if model.isSupported,
                       let recommended = appState.deviceRecommendedModel {
                        // Use exact prefix boundary matching to avoid cross-model
                        // false positives (e.g. "large-v3" matching "large-v3_turbo")
                        let prefix = "openai_whisper-\(model.size.rawValue)"
                        if recommended == prefix || recommended.hasPrefix(prefix + "-") {
                            Text("推荐")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(.blue.opacity(0.2))
                                .foregroundStyle(.blue)
                                .cornerRadius(4)
                        }
                    }

                    if !model.isSupported {
                        Text("实验性")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(.orange.opacity(0.2))
                            .foregroundStyle(.orange)
                            .cornerRadius(4)
                            .help("WhisperKit 尚未验证此模型在你的芯片系列上的兼容性。你的硬件很可能可以运行，但可能比优化模型更慢。")
                    }
                }

                HStack(spacing: 4) {
                    Text(model.size.fileSizeDescription)
                    Text("•")
                    Text(model.size.qualityDescription)
                    Text("•")
                    Text("约 \(String(format: "%.0f", model.size.ramRequiredGB)) GB 内存")
                    Text("•")
                    Text("速度：\(String(repeating: "⚡", count: max(1, 6 - model.size.relativeSpeed)))")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Download progress or loading indicator
            if let progress = model.downloadProgress {
                VStack(spacing: 2) {
                    ProgressView(value: progress)
                        .frame(width: 60)
                        .controlSize(.small)
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else if model.isLoading {
                VStack(spacing: 2) {
                    ProgressView()
                        .frame(width: 60)
                        .controlSize(.small)
                    Text(model.loadingStatus)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Action button
            if model.isActive {
                Label("使用中", systemImage: "checkmark")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else if !model.isSupported {
                if model.isLoading || model.downloadProgress != nil {
                    EmptyView()
                } else if model.isDownloaded {
                    Button("仍要加载") {
                        showForceDownloadAlert = true
                    }
                    .controlSize(.small)
                    .foregroundStyle(.secondary)
                } else {
                    Button("仍要尝试") {
                        showForceDownloadAlert = true
                    }
                    .controlSize(.small)
                    .foregroundStyle(.secondary)
                }
            } else if model.isLoading || model.downloadProgress != nil {
                // Show nothing - progress indicator handles the feedback
                EmptyView()
            } else if model.isDownloaded {
                Button("加载") {
                    Task { @MainActor in await appState.loadModel(model.size) }
                }
                .controlSize(.small)
                .buttonStyle(.borderedProminent)
            } else {
                Button("下载并加载") {
                    Task { @MainActor in
                        await appState.downloadModel(model.size)
                        if appState.availableModels.first(where: { $0.size == model.size })?.isDownloaded == true {
                            await appState.loadModel(model.size)
                        }
                    }
                }
                .controlSize(.small)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .alert("使用实验性模型？", isPresented: $showForceDownloadAlert) {
            Button("取消", role: .cancel) {}
            Button(model.isDownloaded ? "仍要加载" : "下载并加载", role: .destructive) {
                Task { @MainActor in
                    if !model.isDownloaded {
                        await appState.downloadModel(model.size)
                    }
                    if model.isDownloaded || appState.availableModels.first(where: { $0.size == model.size })?.isDownloaded == true {
                        await appState.loadModel(model.size)
                    }
                }
            }
        } message: {
            Text("WhisperKit 尚未验证此模型在你的芯片系列上的兼容性。它很可能可以运行，但可能比优化模型更慢。")
        }
    }
}

// MARK: - Audio Settings

struct AudioSettingsTab: View {
    @EnvironmentObject var appState: AppState
    @State private var audioDevices: [AudioDevice] = []

    var body: some View {
        Form {
            Section("录音") {
                Picker("最长录音时长", selection: $appState.maxRecordingDuration) {
                    Text("15 秒").tag(15)
                    Text("30 秒").tag(30)
                    Text("60 秒").tag(60)
                    Text("120 秒").tag(120)
                    Text("300 秒（5 分钟）").tag(300)
                }

                Text("超过此时长后录音将自动停止。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("静音检测") {
                HStack {
                    Text("灵敏度")
                    Slider(
                        value: $appState.silenceThreshold,
                        in: 0.001...0.05,
                        step: 0.001
                    )
                    Text(sensitivityLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .trailing)
                }

                HStack {
                    Text("静音后自动停止")
                    Slider(
                        value: $appState.silenceDuration,
                        in: 0.5...5.0,
                        step: 0.5
                    )
                    Text("\(String(format: "%.1f", appState.silenceDuration))s")
                        .monospacedDigit()
                        .frame(width: 35)
                }

                Text("在双击切换模式下，静音超过设定时长后录音自动停止。在按住说话模式下，松开按键即可停止。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("音效") {
                Toggle("启用音效", isOn: $appState.soundEffectsEnabled)

                Text("录音开始和停止时播放提示音。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("输入设备") {
                if audioDevices.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                        Text("未找到音频输入设备")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(audioDevices) { device in
                        HStack {
                            Image(systemName: device.isDefault ? "mic.circle.fill" : "mic.circle")
                                .foregroundStyle(device.isDefault ? .blue : .secondary)
                            VStack(alignment: .leading) {
                                Text(device.name)
                                    .font(.callout)
                                if device.isDefault {
                                    Text("系统默认")
                                        .font(.caption2)
                                        .foregroundStyle(.blue)
                                }
                            }
                            Spacer()
                            if device.isDefault {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }

                Button("刷新设备") {
                    audioDevices = AudioEngine.availableInputDevices()
                }
                .controlSize(.small)

                Text("VocaMac 使用系统默认输入设备。请在系统设置 → 声音 → 输入中更改。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .onAppear {
            audioDevices = AudioEngine.availableInputDevices()
        }
    }

    private var sensitivityLabel: String {
        if appState.silenceThreshold < 0.01 { return "高" }
        if appState.silenceThreshold < 0.03 { return "中" }
        return "低"
    }
}

// MARK: - About Tab

struct AboutTab: View {
    @EnvironmentObject var appState: AppState
    @State private var showingUpdateSheet = false
    @State private var updateInfoForSheet: UpdateInfo?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    // App icon
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue)
                        .padding(.top, 8)

                    // App name and version
                    Text("VocaMac")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("你的声音，你的 Mac，你的隐私。\n由 AI 驱动的开源听写工具。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("版本 \(appVersionDisplay)（\(buildChannelLabel)）")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    VStack(spacing: 4) {
                        Button {
                            Task { @MainActor in
                                await appState.updateChecker.checkForUpdates()
                                if case .updateAvailable(let info) = appState.updateChecker.updateState {
                                    updateInfoForSheet = info
                                    showingUpdateSheet = true
                                }
                            }
                        } label: {
                            if case .checking = appState.updateChecker.updateState {
                                HStack(spacing: 6) {
                                    ProgressView()
                                        .controlSize(.small)
                                    Text("正在检查更新…")
                                }
                                .font(.caption)
                            } else {
                                Label("检查更新…", systemImage: "arrow.triangle.2.circlepath")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.blue)

                        if !updateStatusText.isEmpty {
                            Text(updateStatusText)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }

                    Divider()
                        .frame(width: 200)
                        .padding(.top, 4)

                    // Tech info
                    GroupBox {
                        VStack(alignment: .leading, spacing: 4) {
                            if let capabilities = appState.systemCapabilities {
                                InfoRow2(label: "设备", value: capabilities.processorName)
                                InfoRow2(label: "架构", value: capabilities.isAppleSilicon ? "Apple Silicon (ARM64)" : "Intel (x86_64)")
                                InfoRow2(label: "神经网络引擎", value: capabilities.supportsMetalAcceleration ? "可用" : "不可用")
                            }
                            InfoRow2(label: "引擎", value: "WhisperKit")
                            InfoRow2(label: "模型", value: appState.whisperService.loadedModelName ?? "未加载")
                            InfoRow2(label: "存储", value: appState.modelManager.diskUsageDescription())
                        }
                        .font(.caption)
                        .padding(4)
                    }
                    .frame(width: 300)

                    Divider()
                        .frame(width: 200)

                    // Links
                    HStack(spacing: 16) {
                        Link(destination: URL(string: "https://vocamac.com")!) {
                            Label("官网", systemImage: "globe")
                        }
                        Link(destination: URL(string: "https://github.com/fwz233-RE/vocamac-zh-CN")!) {
                            Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                        }
                        Link(destination: URL(string: "https://github.com/argmaxinc/WhisperKit")!) {
                            Label("WhisperKit", systemImage: "waveform")
                        }
                    }
                    .font(.caption)

                    Divider()
                        .frame(width: 200)

                    Button(action: {
                        NotificationCenter.default.post(name: .showOnboarding, object: nil)
                    }) {
                        Label("显示设置向导…", systemImage: "wand.and.stars")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .help("重新运行首次启动设置向导")
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            HStack(spacing: 0) {
                Text("由 ")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Link("Jatin Kumar Malik", destination: URL(string: "https://x.com/intent/user?screen_name=jatinkrmalik")!)
                    .font(.caption2)
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showingUpdateSheet) {
            if let info = updateInfoForSheet {
                UpdateDetailView(info: info)
                    .environmentObject(appState)
            }
        }
    }

    private var appVersionDisplay: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "未知"
    }

    private var buildChannelLabel: String {
        appVersionDisplay.contains("nightly") ? "每夜构建" : "测试版"
    }

    private var updateStatusText: String {
        switch appState.updateChecker.updateState {
        case .upToDate:
            return "你正在使用最新版本。"
        case .updateAvailable(let info):
            return "有可用更新：\(info.tagName)"
        case .error(let message):
            return message
        case .downloading(let progress, _, _, _):
            return "正在下载更新… \(Int(progress * 100))%"
        case .verifying:
            return "正在校验下载完整性…"
        case .readyToInstall:
            return "更新已下载。打开 DMG 文件进行安装。"
        case .checking:
            return "正在检查更新…"
        case .idle:
            return ""
        }
    }
}

// MARK: - Debug Tab

struct DebugTab: View {
    @EnvironmentObject var appState: AppState
    @State private var logEntryCount: Int = VocaLogger.logEntryCount

    var body: some View {
        Form {
            // Permissions
            Section("权限") {
                PermissionRow(
                    name: "麦克风",
                    icon: "mic.fill",
                    status: appState.micPermission,
                    action: { appState.requestMicrophonePermission() }
                )

                PermissionRow(
                    name: "辅助功能",
                    icon: "accessibility",
                    status: appState.accessibilityPermission,
                    action: { appState.requestAccessibilityPermission() }
                )

                PermissionRow(
                    name: "输入监控",
                    icon: "keyboard",
                    status: appState.inputMonitoringPermission,
                    action: { appState.requestInputMonitoringPermission() }
                )

                if appState.micPermission == .denied || appState.accessibilityPermission == .denied || appState.inputMonitoringPermission == .denied {
                    Text("已拒绝的权限需要在系统设置 → 隐私与安全性中手动启用。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Button("重新检查权限") {
                        appState.checkPermissions()
                    }
                    .controlSize(.small)

                    Spacer()

                    Button(action: resetPermissions) {
                        Label("重置所有权限", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(.red)
                    }
                    .controlSize(.small)
                    .help("重置 VocaMac 的所有 TCC 权限。应用将退出，下次启动时需要重新授权。")
                }

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.caption)
                    Text("**升级用户请注意：** VocaMac 现已使用 Developer ID 签名，权限在更新后会保留。如果权限状态异常，可使用上方的重置按钮。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Debug Logs
            Section("调试日志") {
                LabeledContent("日志文件") {
                    Text(VocaLogger.logFileURL().lastPathComponent)
                        .foregroundStyle(.secondary)
                }

                LabeledContent("日志条数") {
                    Text("\(logEntryCount)")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Button(action: copyDebugLogs) {
                        Label("复制到剪贴板", systemImage: "doc.on.clipboard")
                    }
                    .help("将最近 500 行日志复制到剪贴板")

                    Spacer()

                    Button(action: exportDebugLogs) {
                        Label("导出到文件…", systemImage: "square.and.arrow.up")
                    }
                    .help("保存调试日志到文件并在 Finder 中显示")

                    Spacer()

                    Button(action: {
                        VocaLogger.clearLogs()
                        logEntryCount = VocaLogger.logEntryCount
                    }) {
                        Label("清除", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                    .help("清除所有日志条目")
                }

                Text("复制或导出最近的应用日志，用于故障排查。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Application
            Section("应用") {
                HStack {
                    Button(action: restartApp) {
                        Label("重启 VocaMac", systemImage: "arrow.trianglehead.clockwise")
                    }
                    .help("退出并重新启动 VocaMac")

                    Spacer()

                    Button(role: .destructive, action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Label("退出 VocaMac", systemImage: "power")
                    }
                    .help("退出 VocaMac")
                }

                Text("重启可解决权限或音频设备相关的问题。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Actions

    private func resetPermissions() {
        let alert = NSAlert()
        alert.messageText = "重置所有权限？"
        alert.informativeText = "这将清除 VocaMac 的所有权限授权（麦克风、辅助功能、输入监控）。应用将退出，下次启动时需要重新授权。\n\n当权限状态异常或更新后未被识别时，此操作很有用。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "重置并退出")
        alert.addButton(withTitle: "取消")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Run tccutil to reset all TCC permissions for this app
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/tccutil")
            task.arguments = ["reset", "All", "com.vocamac.app"]
            try? task.run()
            task.waitUntilExit()

            VocaLogger.info(.general, "TCC permissions reset via tccutil")

            // Quit the app so permissions take effect on next launch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    private func restartApp() {
        let bundlePath = Bundle.main.bundlePath
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-n", bundlePath, "--args", "--restarted"]
        try? task.run()

        // Give the new instance a moment to start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApplication.shared.terminate(nil)
        }
    }

    // MARK: - Debug Log Actions

    private func copyDebugLogs() {
        let logs = VocaLogger.exportLogs(lastLines: 500)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(logs, forType: .string)
    }

    private func exportDebugLogs() {
        let logs = VocaLogger.exportLogs(lastLines: 1000)

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.plainText]
        savePanel.nameFieldStringValue = "VocaMac-Debug-\(ISO8601DateFormatter().string(from: Date()).prefix(19)).log"
        savePanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser

        savePanel.begin { response in
            if response == .OK, let fileURL = savePanel.url {
                do {
                    try logs.write(to: fileURL, atomically: true, encoding: .utf8)
                    NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: fileURL.deletingLastPathComponent().path)
                } catch {
                    VocaLogger.error(.general, "Failed to export logs: \(error)")
                }
            }
        }
    }
}

struct InfoRow2: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .trailing)
            Text(value)
                .fontWeight(.medium)
            Spacer()
        }
    }
}
