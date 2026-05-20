// ChineseScriptNormalizerTests.swift
// VocaMac Tests

import XCTest
@testable import VocaMac

final class ChineseScriptNormalizerTests: XCTestCase {

    func testToSimplifiedConvertsTraditionalCharacters() {
        XCTAssertEqual(ChineseScriptNormalizer.toSimplified("臺灣"), "台湾")
        XCTAssertEqual(ChineseScriptNormalizer.toSimplified("軟體"), "软体")
    }

    func testToSimplifiedLeavesSimplifiedUnchanged() {
        XCTAssertEqual(ChineseScriptNormalizer.toSimplified("台湾"), "台湾")
    }

    func testToSimplifiedLeavesNonChineseUnchanged() {
        XCTAssertEqual(ChineseScriptNormalizer.toSimplified("Hello 世界"), "Hello 世界")
    }

    func testApplyWhenEnabledConverts() {
        XCTAssertEqual(
            ChineseScriptNormalizer.apply(to: "臺灣", simplifiedChineseEnabled: true),
            "台湾"
        )
    }

    func testApplyWhenDisabledSkipsConversion() {
        XCTAssertEqual(
            ChineseScriptNormalizer.apply(to: "臺灣", simplifiedChineseEnabled: false),
            "臺灣"
        )
    }
}
