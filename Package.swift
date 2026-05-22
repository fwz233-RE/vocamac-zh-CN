// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift Package Manager required to build this package.

import PackageDescription

let package = Package(
    name: "VocaMac",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "VocaMac",
            targets: ["VocaMac"]
        )
    ],
    dependencies: [
        // WhisperKit — local, on-device speech-to-text powered by CoreML
        // https://github.com/argmaxinc/WhisperKit
        .package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "0.9.4"),
    ],
    targets: [
        // Objective-C helpers used by the Swift app.
        .target(
            name: "VocaMacObjC",
            path: "Sources/VocaMacObjC",
            publicHeadersPath: "include"
        ),
        // Clang bridge to the vendored sherpa-onnx static library.
        .target(
            name: "VocaMacSherpaBridge",
            path: "Sources/VocaMacSherpaBridge",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("../../Vendor/sherpa-onnx.xcframework/macos-arm64_x86_64/Headers"),
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
                .unsafeFlags(["-L", "Sources/VocaMacSherpaBridge/lib"]),
                .linkedLibrary("sherpa-onnx"),
                .linkedLibrary("onnxruntime"),
            ]
        ),
        // Offline punctuation restoration (sherpa-onnx CT-Transformer).
        .target(
            name: "VocaMacPunctuation",
            dependencies: ["VocaMacSherpaBridge"],
            path: "Sources/VocaMacPunctuation",
            linkerSettings: [
                .linkedLibrary("c++"),
                .unsafeFlags(["-L", "Sources/VocaMacSherpaBridge/lib"]),
                .linkedLibrary("sherpa-onnx"),
                .linkedLibrary("onnxruntime"),
            ]
        ),
        // Main application target
        .executableTarget(
            name: "VocaMac",
            dependencies: [
                "VocaMacObjC",
                "VocaMacPunctuation",
                .product(name: "WhisperKit", package: "WhisperKit"),
            ],
            path: "Sources/VocaMac",
            resources: [
                .copy("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        ),
        // Test target
        .testTarget(
            name: "VocaMacTests",
            dependencies: ["VocaMac"],
            path: "Tests/VocaMacTests"
        ),
        .testTarget(
            name: "VocaMacPunctuationTests",
            dependencies: ["VocaMacPunctuation"],
            path: "Tests/VocaMacPunctuationTests"
        )
    ]
)
