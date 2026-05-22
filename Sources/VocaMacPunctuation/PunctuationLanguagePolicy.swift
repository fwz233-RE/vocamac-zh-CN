// PunctuationLanguagePolicy.swift
// VocaMacPunctuation
//
// Decides when offline punctuation restoration should run.

import Foundation

/// Language and content heuristics for the zh-en CT-Transformer model.
public enum PunctuationLanguagePolicy {

    /// Returns true when punctuation restoration is appropriate for the given language and text.
    public static func shouldRestorePunctuation(language: String?, text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        let code = language?.lowercased()

        if code == nil || code == "auto" {
            return containsCJK(trimmed) || isMostlyLatin(trimmed)
        }

        switch code {
        case "zh", "yue", "en":
            return true
        default:
            return containsCJK(trimmed)
        }
    }

    private static func containsCJK(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            switch scalar.value {
            case 0x4E00...0x9FFF, 0x3400...0x4DBF, 0xF900...0xFAFF:
                return true
            default:
                return false
            }
        }
    }

    private static func isMostlyLatin(_ text: String) -> Bool {
        let letters = text.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        guard !letters.isEmpty else { return false }
        let latinCount = letters.filter { $0.value <= 0x024F }.count
        return Double(latinCount) / Double(letters.count) > 0.8
    }
}
