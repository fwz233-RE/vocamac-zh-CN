// TextPunctuating.swift
// VocaMacPunctuation
//
// Public protocol for offline punctuation restoration.

import Foundation

// MARK: - Errors

public enum PunctuationError: LocalizedError, Sendable {
    case modelNotReady
    case modelNotFound
    case inferenceFailed(reason: String)

    public var errorDescription: String? {
        switch self {
        case .modelNotReady:
            return "标点模型尚未就绪。"
        case .modelNotFound:
            return "标点模型未内置，请重新安装应用。"
        case .inferenceFailed(let reason):
            return "标点恢复失败：\(reason)"
        }
    }
}

// MARK: - TextPunctuating

/// Restores punctuation marks in transcribed text (offline / batch mode).
public protocol TextPunctuating: Sendable {
    /// Whether the engine has a loaded model ready for inference.
    var isReady: Bool { get }

    /// Whether the bundled ONNX model file exists.
    var isModelAvailable: Bool { get }

    /// Verify the bundled model is present (no network download).
    func prepareModel(onProgress: (@Sendable (Double) -> Void)?) async throws

    /// Add punctuation to `text`. Returns the original string when `text` is empty.
    func addPunctuation(to text: String, language: String?) async throws -> String
}
