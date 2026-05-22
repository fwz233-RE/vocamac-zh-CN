// PunctuationLanguagePolicyTests.swift
// VocaMacPunctuation Tests

import XCTest
@testable import VocaMacPunctuation

final class PunctuationLanguagePolicyTests: XCTestCase {

    func testEmptyTextIsSkipped() {
        XCTAssertFalse(PunctuationLanguagePolicy.shouldRestorePunctuation(language: "zh", text: "   "))
    }

    func testChineseLanguageAlwaysPunctuates() {
        XCTAssertTrue(PunctuationLanguagePolicy.shouldRestorePunctuation(language: "zh", text: "你好世界"))
    }

    func testEnglishLanguagePunctuates() {
        XCTAssertTrue(PunctuationLanguagePolicy.shouldRestorePunctuation(language: "en", text: "hello world"))
    }

    func testAutoDetectsCJK() {
        XCTAssertTrue(PunctuationLanguagePolicy.shouldRestorePunctuation(language: "auto", text: "今天天气不错"))
    }

    func testJapaneseWithoutCJKPolicySkipsLatinOnly() {
        XCTAssertFalse(PunctuationLanguagePolicy.shouldRestorePunctuation(language: "ja", text: "konnichiwa"))
    }

    func testJapaneseWithCJKStillPunctuates() {
        XCTAssertTrue(PunctuationLanguagePolicy.shouldRestorePunctuation(language: "ja", text: "今日は良い天気"))
    }
}
