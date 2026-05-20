// UpdateView.swift
// VocaMac
//
// Update banner and detail sheet for GitHub release updates.

import SwiftUI

struct UpdateBannerView: View {
    let info: UpdateInfo
    @EnvironmentObject var appState: AppState
    @State private var showingDetails = false

    var body: some View {
        Button {
            showingDetails = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundStyle(.blue)
                Text("有可用更新 \(info.tagName)")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetails) {
            UpdateDetailView(info: info)
                .environmentObject(appState)
        }
    }
}

struct UpdateDetailView: View {
    let info: UpdateInfo
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("VocaMac \(info.tagName) 可用")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(ByteCountFormatter.string(fromByteCount: Int64(info.dmgSize), countStyle: .file))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("稍后（24 小时）") {
                    appState.updateChecker.dismiss()
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()

            ScrollView {
                Text(info.releaseNotes.isEmpty ? "未提供发行说明。" : info.releaseNotes)
                    .font(.callout)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
            }
            .frame(maxHeight: 280)

            Divider()

            actionArea
                .padding(20)
        }
        .frame(width: 480)
    }

    @ViewBuilder
    private var actionArea: some View {
        switch appState.updateChecker.updateState {
        case .updateAvailable:
            HStack {
                Button("跳过此版本") {
                    appState.updateChecker.skipVersion(info.version)
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Spacer()

                Button("下载并安装") {
                    Task { @MainActor in
                        await appState.updateChecker.downloadUpdate(info)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        case .downloading(let progress, let bytesDownloaded, let totalBytes, let eta):
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("正在下载更新…")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(.blue)
                HStack {
                    Text("\(ByteCountFormatter.string(fromByteCount: bytesDownloaded, countStyle: .file)) / \(ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file))")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    if eta > 0 && eta < 3600 {
                        Text(formatETA(eta))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        case .verifying:
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text("正在校验下载完整性…")
                        .foregroundStyle(.secondary)
                }
            }
        case .readyToInstall(let dmgPath):
            VStack(alignment: .leading, spacing: 10) {
                Label("下载完成", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("打开 DMG 文件，将 VocaMac 拖入「应用程序」文件夹以替换现有版本。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("打开 DMG") {
                    appState.updateChecker.openDMG(at: dmgPath)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        case .error(let message):
            VStack(alignment: .leading, spacing: 10) {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)

                HStack {
                    Button("查看发布页") {
                        NSWorkspace.shared.open(info.releasePageURL)
                    }
                    .buttonStyle(.bordered)

                    Button("重试") {
                        Task { @MainActor in
                            await appState.updateChecker.downloadUpdate(info)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        default:
            EmptyView()
        }
    }

    private func formatETA(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 {
            return "剩余 \(mins) 分 \(secs) 秒"
        }
        return "剩余 \(secs) 秒"
    }
}
