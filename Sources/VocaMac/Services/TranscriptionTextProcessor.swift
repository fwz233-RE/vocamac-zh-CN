// TranscriptionTextProcessor.swift
// VocaMac
//
// Post-transcription text pipeline: punctuation restoration and script normalization.

import Foundation
import VocaMacPunctuation

/// Applies optional punctuation and Chinese script normalization to transcribed text.
struct TranscriptionTextProcessor {

    let punctuation: TextPunctuating

    /// Process raw Whisper output into text ready for injection.
    func process(
        text: String,
        language: String?,
        simplifiedChineseEnabled: Bool,
        punctuationEnabled: Bool
    ) async -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var output = trimmed

        if punctuationEnabled {
            do {
                output = try await punctuation.addPunctuation(to: output, language: language)
            } catch {
                VocaLogger.warning(
                    .punctuation,
                    "Punctuation failed, using original text: \(error.localizedDescription)"
                )
            }
        }

        return ChineseScriptNormalizer.apply(
            to: output,
            simplifiedChineseEnabled: simplifiedChineseEnabled
        )
    }
}
