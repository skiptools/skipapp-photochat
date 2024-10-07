// swift-tools-version: 5.9
// This is a Skip (https://skip.tools) package,
// containing a Swift Package Manager project
// that will use the Skip build plugin to transpile the
// Swift Package, Sources, and Tests into an
// Android Gradle Project with Kotlin sources and JUnit tests.
import PackageDescription
import Foundation

let package = Package(
    name: "skipapp-photochat",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
        .library(name: "PhotoChatApp", type: .dynamic, targets: ["PhotoChat"]),
        .library(name: "PhotoChatModel", targets: ["PhotoChatModel"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.0.0"),
        .package(url: "https://source.skip.tools/skip-sql.git", "0.0.0"..<"2.0.0"),
        .package(url: "https://source.skip.tools/skip-kit.git", "0.0.0"..<"2.0.0")
    ],
    targets: [
        .target(name: "PhotoChat", dependencies: [
            "PhotoChatModel",
            .product(name: "SkipKit", package: "skip-kit")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),

        .testTarget(name: "PhotoChatTests", dependencies: [
            "PhotoChat",
            .product(name: "SkipTest", package: "skip")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),

        .target(name: "PhotoChatModel", dependencies: [
            .product(name: "SkipSQL", package: "skip-sql")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),

        .testTarget(name: "PhotoChatModelTests", dependencies: [
            "PhotoChatModel",
            .product(name: "SkipTest", package: "skip")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
