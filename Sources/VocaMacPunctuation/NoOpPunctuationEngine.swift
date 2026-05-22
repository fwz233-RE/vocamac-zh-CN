// NoOpPunctuationEngine.swift
// VocaMacPunctuation
//
// Pass-through engine used when punctuation is disabled or in tests.

import Foundation

/// Returns input text unchanged; performs no model loading or inference.
public struct NoOpPunctuationEngine: TextPunctuating, Sendable {

    public init() {}

    public var isReady: Bool { true }

    public var isModelAvailable: Bool { true }

    public func prepareModel(onProgress: (@Sendable (Double) -> Void)?) async throws {
        onProgress?(1.0)
    }

    public func addPunctuation(to text: String, language: String?) async throws -> String {
        text
    }
}
