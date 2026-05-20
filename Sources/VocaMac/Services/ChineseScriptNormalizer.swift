// ChineseScriptNormalizer.swift
// VocaMac
//
// Normalizes transcribed Chinese text to simplified characters using
// the system ICU transform (Traditional → Simplified).

import Foundation

/// Converts traditional Chinese characters in transcription output to simplified.
enum ChineseScriptNormalizer {

    private static let traditionalToSimplified = StringTransform(rawValue: "Traditional-Simplified")

    /// Returns simplified Chinese when `enabled` is true; otherwise returns `text` unchanged.
    static func apply(to text: String, simplifiedChineseEnabled enabled: Bool) -> String {
        guard enabled else { return text }
        return toSimplified(text)
    }

    /// Converts traditional Chinese characters to simplified; non-Chinese text is unchanged.
    static func toSimplified(_ text: String) -> String {
        text.applyingTransform(traditionalToSimplified, reverse: false) ?? text
    }
}
