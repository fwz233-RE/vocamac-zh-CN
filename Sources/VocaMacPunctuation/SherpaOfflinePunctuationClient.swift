// SherpaOfflinePunctuationClient.swift
// VocaMacPunctuation
//
// Thin Swift wrapper over the sherpa-onnx offline punctuation C API.

import Foundation
import VocaMacSherpaBridge

enum SherpaOfflinePunctuationClient {

    /// Add punctuation using the CT-Transformer model at `modelPath`. CPU only.
    static func addPunctuation(text: String, modelPath: String) throws -> String {
        guard !text.isEmpty else { return text }

        return try modelPath.withCString { modelCString in
            try "cpu".withCString { providerCString in
                let modelConfig = SherpaOnnxOfflinePunctuationModelConfig(
                    ct_transformer: modelCString,
                    num_threads: 2,
                    debug: 0,
                    provider: providerCString
                )
                var config = SherpaOnnxOfflinePunctuationConfig(model: modelConfig)

                guard let engine = SherpaOnnxCreateOfflinePunctuation(&config) else {
                    throw PunctuationError.inferenceFailed(reason: "SherpaOnnxCreateOfflinePunctuation returned nil")
                }
                defer { SherpaOnnxDestroyOfflinePunctuation(engine) }

                return try text.withCString { textCString in
                    guard let resultCString = SherpaOfflinePunctuationAddPunct(engine, textCString) else {
                        throw PunctuationError.inferenceFailed(reason: "SherpaOfflinePunctuationAddPunct returned nil")
                    }
                    defer { SherpaOfflinePunctuationFreeText(resultCString) }
                    return String(cString: resultCString)
                }
            }
        }
    }
}
