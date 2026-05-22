// TranscriptionTextProcessorTests.swift
// VocaMac Tests

import XCTest
@testable import VocaMac
import VocaMacPunctuation

@MainActor
final class TranscriptionTextProcessorTests: XCTestCase {

    func testAppliesPunctuationWhenEnabled() async {
        let mock = MockTextPunctuating()
        mock.punctuatedText = "你好，世界。"
        let processor = TranscriptionTextProcessor(punctuation: mock)

        let result = await processor.process(
            text: "你好世界",
            language: "zh",
            simplifiedChineseEnabled: false,
            punctuationEnabled: true
        )

        XCTAssertEqual(result, "你好，世界。")
        XCTAssertEqual(mock.addPunctuationCallCount, 1)
    }

    func testSkipsPunctuationWhenDisabled() async {
        let mock = MockTextPunctuating()
        let processor = TranscriptionTextProcessor(punctuation: mock)

        let result = await processor.process(
            text: "你好世界",
            language: "zh",
            simplifiedChineseEnabled: false,
            punctuationEnabled: false
        )

        XCTAssertEqual(result, "你好世界")
        XCTAssertEqual(mock.addPunctuationCallCount, 0)
    }

    func testPunctuationFailureFallsBackToOriginal() async {
        let mock = MockTextPunctuating()
        mock.shouldThrow = true
        let processor = TranscriptionTextProcessor(punctuation: mock)

        let result = await processor.process(
            text: "臺灣",
            language: "zh",
            simplifiedChineseEnabled: true,
            punctuationEnabled: true
        )

        XCTAssertEqual(result, "台湾")
    }
}
