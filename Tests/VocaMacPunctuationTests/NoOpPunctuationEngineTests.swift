// NoOpPunctuationEngineTests.swift
// VocaMacPunctuation Tests

import XCTest
@testable import VocaMacPunctuation

final class NoOpPunctuationEngineTests: XCTestCase {

    func testReturnsInputUnchanged() async throws {
        let engine = NoOpPunctuationEngine()
        let result = try await engine.addPunctuation(to: "你好世界", language: "zh")
        XCTAssertEqual(result, "你好世界")
    }

    func testPrepareModelCompletes() async throws {
        let engine = NoOpPunctuationEngine()
        var progress: Double = 0
        try await engine.prepareModel { value in
            progress = value
        }
        XCTAssertEqual(progress, 1.0)
        XCTAssertTrue(engine.isReady)
    }
}
