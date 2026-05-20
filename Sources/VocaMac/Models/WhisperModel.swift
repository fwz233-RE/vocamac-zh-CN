// WhisperModel.swift
// VocaMac
//
// Model metadata types for whisper model variants and their runtime state.

import Foundation

// MARK: - ModelSize

/// Whisper model size variants with their properties
enum ModelSize: String, CaseIterable, Codable, Identifiable {
    case tiny     = "tiny"
    case base     = "base"
    case small    = "small"
    case medium   = "medium"
    case largeV3  = "large-v3"

    var id: String { rawValue }

    /// Human-readable display name
    var displayName: String {
        switch self {
        case .tiny:    return "微型（最快）"
        case .base:    return "基础"
        case .small:   return "小型"
        case .medium:  return "中型"
        case .largeV3: return "Large v3（最佳质量）"
        }
    }

    /// Approximate file size on disk in bytes
    var fileSizeBytes: Int64 {
        switch self {
        case .tiny:    return 39_000_000
        case .base:    return 142_000_000
        case .small:   return 466_000_000
        case .medium:  return 1_500_000_000
        case .largeV3: return 3_100_000_000
        }
    }

    /// Human-readable file size string
    var fileSizeDescription: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSizeBytes)
    }

    /// Approximate RAM required for inference in GB
    var ramRequiredGB: Double {
        switch self {
        case .tiny:    return 1.0
        case .base:    return 1.5
        case .small:   return 2.0
        case .medium:  return 5.0
        case .largeV3: return 10.0
        }
    }

    /// Relative speed indicator (1 = fastest)
    var relativeSpeed: Int {
        switch self {
        case .tiny:    return 1
        case .base:    return 2
        case .small:   return 4
        case .medium:  return 8
        case .largeV3: return 16
        }
    }

    /// Accuracy quality descriptor
    var qualityDescription: String {
        switch self {
        case .tiny:    return "良好"
        case .base:    return "较好"
        case .small:   return "很好"
        case .medium:  return "优秀"
        case .largeV3: return "最佳"
        }
    }
}

// MARK: - WhisperModelInfo

/// Runtime state for a specific model variant
struct WhisperModelInfo: Identifiable {
    /// Which model size this represents
    let size: ModelSize

    /// Local file/folder path if downloaded
    var filePath: URL?

    /// Whether the model is downloaded and available on disk
    var isDownloaded: Bool

    /// Whether this model is currently loaded and active
    var isActive: Bool

    /// Whether this model is supported on the current device (per WhisperKit recommendation)
    var isSupported: Bool

    /// Download progress (0.0 to 1.0), nil when not downloading
    var downloadProgress: Double?

    /// Whether this model is currently being loaded into memory
    var isLoading: Bool = false

    /// Descriptive loading phase (e.g., "Preparing…", "Compiling…")
    var loadingStatus: String = "加载中…"

    var id: String { size.id }

    /// Human-readable status description
    var statusDescription: String {
        if isActive { return "使用中" }
        if isLoading { return loadingStatus }
        if let progress = downloadProgress {
            return "下载中（\(Int(progress * 100))%）"
        }
        if isDownloaded { return "已下载" }
        return "未下载"
    }

    /// SF Symbol name for the status icon
    var statusIconName: String {
        if isActive { return "checkmark.circle.fill" }
        if isLoading { return "arrow.trianglehead.2.clockwise" }
        if downloadProgress != nil { return "arrow.down.circle" }
        if isDownloaded { return "checkmark.circle" }
        return "arrow.down.to.line"
    }
}
