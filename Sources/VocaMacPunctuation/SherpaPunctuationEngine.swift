// SherpaPunctuationEngine.swift
// VocaMacPunctuation
//
// Production punctuation engine backed by sherpa-onnx CT-Transformer int8.

import Foundation

/// Offline punctuation restoration using sherpa-onnx on CPU.
public final class SherpaPunctuationEngine: TextPunctuating, @unchecked Sendable {

    private let store: PunctuationModelStore
    private let lock = NSLock()
    private var isEngineReady = false

    public init(store: PunctuationModelStore = .shared) {
        self.store = store
        if store.isModelAvailable {
            isEngineReady = true
        }
    }

    public var isReady: Bool {
        lock.lock()
        defer { lock.unlock() }
        return isEngineReady && store.isModelAvailable
    }

    public var isModelAvailable: Bool {
        store.isModelAvailable
    }

    public func prepareModel(onProgress: (@Sendable (Double) -> Void)? = nil) async throws {
        guard store.isModelAvailable else {
            throw PunctuationError.modelNotFound
        }
        setEngineReady(true)
        onProgress?(1.0)
    }

    public func addPunctuation(to text: String, language: String?) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return text }

        guard PunctuationLanguagePolicy.shouldRestorePunctuation(language: language, text: trimmed) else {
            return text
        }

        guard store.isModelAvailable else {
            throw PunctuationError.modelNotFound
        }

        guard engineIsReady() else {
            throw PunctuationError.modelNotReady
        }

        let modelPath = store.modelFileURL.path

        do {
            let punctuated = try await Task.detached(priority: .userInitiated) {
                try SherpaOfflinePunctuationClient.addPunctuation(text: trimmed, modelPath: modelPath)
            }.value

            return punctuated.isEmpty ? text : punctuated
        } catch let error as PunctuationError {
            throw error
        } catch {
            throw PunctuationError.inferenceFailed(reason: error.localizedDescription)
        }
    }

    private func setEngineReady(_ ready: Bool) {
        lock.lock()
        isEngineReady = ready
        lock.unlock()
    }

    private func engineIsReady() -> Bool {
        lock.lock()
        let ready = isEngineReady
        lock.unlock()
        return ready
    }
}
