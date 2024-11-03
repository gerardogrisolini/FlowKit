// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FlowKit",
    platforms: [.iOS(.v15), .macOS(.v14)],
    products: [
        .library(
            name: "FlowKit",
            type: .static,
            targets: ["FlowKit"]
        ),
        .library(
            name: "FlowCases",
            targets: ["FlowCases"]
        ),
        .library(
            name: "FlowView",
            targets: ["FlowView"]
        ),
        .library(
            name: "Flow",
            targets: ["Flow"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Resolver.git", from: "1.5.1"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.1.1"),
//        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .macro(
            name: "FlowCasesMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .macro(
            name: "FlowViewMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .macro(
            name: "FlowMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "FlowCases",
            dependencies: ["FlowCasesMacro"]
        ),
        .target(
            name: "FlowView",
            dependencies: ["FlowViewMacro"]
        ),
        .target(
            name: "Flow",
            dependencies: ["FlowMacro"]
        ),
        .target(
            name: "FlowKit",
            dependencies: ["Resolver", "FlowCases", "FlowView", "Flow"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=complete", .when(platforms: [.macOS, .iOS]))
            ]
        ),
        .testTarget(
            name: "FlowKitTests",
            dependencies:  [
                "FlowKit",
                "FlowCasesMacro",
                "FlowViewMacro",
                "Flow",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
