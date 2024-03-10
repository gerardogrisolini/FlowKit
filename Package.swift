// swift-tools-version: 5.9
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
            name: "EnumAllCases",
            targets: ["EnumAllCases"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Resolver.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
//        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .macro(
            name: "EnumAllCasesMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "EnumAllCases",
            dependencies: ["EnumAllCasesMacro"]
        ),
        .target(
            name: "FlowKit",
            dependencies: ["Resolver", "EnumAllCases"]
        ),
        .testTarget(
            name: "FlowKitTests",
            dependencies:  [
                "FlowKit",
                "EnumAllCasesMacro",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        )
    ]
)
