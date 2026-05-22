// PunctuationModelStore.swift
// VocaMacPunctuation
//
// Resolves the bundled sherpa-onnx CT-Transformer int8 punctuation model.

import Foundation

/// Locates the punctuation ONNX model shipped inside the app bundle.
public struct PunctuationModelStore: Sendable {

    public static let shared = PunctuationModelStore()

    public static let modelFileName = "model.int8.onnx"
    private static let bundledRelativePath = "BundledModels/punctuation"

    private var fileManager: FileManager { .default }

    public init() {}

    /// Expected directory inside `Contents/Resources/`.
    public static var bundledModelDirectoryName: String { bundledRelativePath }

    /// URL of the bundled model file, if present.
    public var bundledModelURL: URL? {
        guard let resources = Bundle.main.resourceURL else { return nil }
        let url = resources
            .appendingPathComponent(Self.bundledRelativePath, isDirectory: true)
            .appendingPathComponent(Self.modelFileName)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    /// Path passed to sherpa-onnx for inference.
    public var modelFileURL: URL {
        if let bundledModelURL {
            return bundledModelURL
        }
        // Fallback for clearer error messages when the bundle is incomplete.
        return Bundle.main.resourceURL?
            .appendingPathComponent(Self.bundledRelativePath, isDirectory: true)
            .appendingPathComponent(Self.modelFileName)
            ?? URL(fileURLWithPath: "/\(Self.bundledRelativePath)/\(Self.modelFileName)")
    }

    public var isModelAvailable: Bool {
        bundledModelURL != nil
    }
}
