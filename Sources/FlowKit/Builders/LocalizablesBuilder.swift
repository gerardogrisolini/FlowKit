//
//  LocalizablesBuilder.swift
//  
//
//  Created by Gerardo Grisolini on 20/02/24.
//

import SwiftUI

public protocol LocalizableJoinProtocol {
    associatedtype From: Localizable
    associatedtype To: Localizable

    var from: From { get }
    var to: To { get }
}

public struct LocalizableJoin<From: Localizable, To: Localizable>: LocalizableJoinProtocol {
    public let from: From
    public let to: To

    public init(_ from: From, _ to: To) {
        self.from = from
        self.to = to
    }
}

@resultBuilder
public enum LocalizablesBuilder {
    public static func buildBlock() -> [any LocalizableJoinProtocol] { [] }

    public static func buildBlock(_ components: (any LocalizableJoinProtocol)...) -> [any LocalizableJoinProtocol]  {
        components
    }

    public static func buildBlock(_ components: [any LocalizableJoinProtocol]...) -> [any LocalizableJoinProtocol]  {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[any LocalizableJoinProtocol]]) -> [any LocalizableJoinProtocol]  {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: any LocalizableJoinProtocol) -> [any LocalizableJoinProtocol] {
        [expression]
    }

    public static func buildOptional(_ components: [any LocalizableJoinProtocol]?) -> [any LocalizableJoinProtocol]  {
        components ?? []
    }

    public static func buildEither(first components: [any LocalizableJoinProtocol]) -> [any LocalizableJoinProtocol]  {
        components
    }

    public static func buildEither(second components: [any LocalizableJoinProtocol]) -> [any LocalizableJoinProtocol]  {
        components
    }

    public static func buildPartialBlock(first: [any LocalizableJoinProtocol]) -> [any LocalizableJoinProtocol] {
        first
    }

    public static func buildPartialBlock(accumulated: [any LocalizableJoinProtocol], next: [any LocalizableJoinProtocol]) -> [any LocalizableJoinProtocol] {
        accumulated + next
    }
}

infix operator ~
public func ~<From: Localizable, To: Localizable>(from: From, to: To) -> any LocalizableJoinProtocol {
    LocalizableJoin(from, to)
}
