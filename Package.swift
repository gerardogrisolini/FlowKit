// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FlowKit",
    platforms: [.macOS(.v14), .iOS(.v16), .macCatalyst(.v13)],
    products: [
        .library(
            name: "FlowKit",
            targets: ["FlowKit"]
        ),
        .library(
            name: "NavigationKit",
            targets: ["NavigationKit"]
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
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            revision: "4799286537280063c85a32f09884cfbca301b1a1"
        ),
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
            exclude: ["Flow.swift", "FlowCases.swift", "FlowMacro.swift", "FlowView.swift", "FlowViewMacro.swift"],
            sources: ["FlowCasesMacro.swift"]
        ),
        .macro(
            name: "FlowViewMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/FlowKitMacro",
            exclude: ["Flow.swift", "FlowCases.swift", "FlowCasesMacro.swift", "FlowMacro.swift", "FlowView.swift"],
            sources: ["FlowViewMacro.swift"]
        ),
        .macro(
            name: "FlowMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/FlowKitMacro",
            exclude: ["FlowCases.swift", "FlowCasesMacro.swift", "Flow.swift", "FlowView.swift", "FlowViewMacro.swift"],
            sources: ["FlowMacro.swift"]
        ),
        .target(
            name: "FlowCases",
            dependencies: ["FlowCasesMacro"],
            path: "Sources/FlowKitMacro",
            exclude: ["Flow.swift", "FlowCasesMacro.swift", "FlowMacro.swift", "FlowView.swift", "FlowViewMacro.swift"],
            sources: ["FlowCases.swift"]
        ),
        .target(
            name: "FlowView",
            dependencies: ["FlowViewMacro"],
            path: "Sources/FlowKitMacro",
            exclude: ["Flow.swift", "FlowCases.swift", "FlowCasesMacro.swift", "FlowMacro.swift", "FlowViewMacro.swift"],
            sources: ["FlowView.swift"]
        ),
        .target(
            name: "Flow",
            dependencies: ["FlowMacro"],
            path: "Sources/FlowKitMacro",
            exclude: ["FlowCases.swift", "FlowCasesMacro.swift", "FlowMacro.swift", "FlowView.swift", "FlowViewMacro.swift"],
            sources: ["Flow.swift"]
        ),
        .target(
            name: "NavigationKit",
            dependencies: ["FlowCases"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=complete")
            ]
        ),
        .target(
            name: "FlowKit",
            dependencies: ["NavigationKit", "FlowView", "Flow"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=complete")
            ]
        ),
        .testTarget(
            name: "NavigationKitTests",
            dependencies:  [
                "NavigationKit"
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
