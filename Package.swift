// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FlowKit",
    platforms: [.macOS(.v14), .iOS(.v15), .macCatalyst(.v14)],
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
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
//        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .macro(
            name: "FlowCasesMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/FlowKitMacro",
            sources: ["FlowCasesMacro.swift"]
        ),
        .macro(
            name: "FlowViewMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/FlowKitMacro",
            sources: ["FlowViewMacro.swift"]
        ),
        .macro(
            name: "FlowMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/FlowKitMacro",
            sources: ["FlowMacro.swift"]
        ),
        .target(
            name: "FlowCases",
            dependencies: ["FlowCasesMacro"],
            path: "Sources/FlowKitMacro",
            sources: ["FlowCases.swift"]
        ),
        .target(
            name: "FlowView",
            dependencies: ["FlowViewMacro"],
            path: "Sources/FlowKitMacro",
            sources: ["FlowView.swift"]
        ),
        .target(
            name: "Flow",
            dependencies: ["FlowMacro"],
            path: "Sources/FlowKitMacro",
            sources: ["Flow.swift"]
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
                "FlowKit"
            ]
        ),
        .testTarget(
            name: "FlowKitMacroTests",
            dependencies:  [
                "FlowMacro",
                "FlowViewMacro",
                "FlowCasesMacro",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
