//
//  OutsBuilder.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 20/02/24.
//

import SwiftUI

public protocol OutJoinProtocol {
    associatedtype Key: FlowOutProtocol

    var from: Key { get }
    var to: Out { get }
}

public struct OutJoin<T: FlowOutProtocol>: OutJoinProtocol {
    public let from: T
    public let to: Out

    public init(_ from: T, _ to: @escaping @Sendable Out) {
        self.from = from
        self.to = to
    }
}

@resultBuilder
public enum OutsBuilder {
    public static func buildBlock() -> [any OutJoinProtocol] { [] }

    public static func buildBlock(_ components: (any OutJoinProtocol)...) -> [any OutJoinProtocol]  {
        components
    }

    public static func buildBlock(_ components: [any OutJoinProtocol]...) -> [any OutJoinProtocol]  {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[any OutJoinProtocol]]) -> [any OutJoinProtocol]  {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: any OutJoinProtocol) -> [any OutJoinProtocol] {
        [expression]
    }

    public static func buildOptional(_ components: [any OutJoinProtocol]?) -> [any OutJoinProtocol]  {
        components ?? []
    }

    public static func buildEither(first components: [any OutJoinProtocol]) -> [any OutJoinProtocol]  {
        components
    }

    public static func buildEither(second components: [any OutJoinProtocol]) -> [any OutJoinProtocol]  {
        components
    }

    public static func buildPartialBlock(first: [any OutJoinProtocol]) -> [any OutJoinProtocol] {
        first
    }

    public static func buildPartialBlock(accumulated: [any OutJoinProtocol], next: [any OutJoinProtocol]) -> [any OutJoinProtocol] {
        accumulated + next
    }
}

infix operator ~
public func ~<T: FlowOutProtocol>(from: T, to: @escaping @Sendable Out) -> any OutJoinProtocol {
    OutJoin(from, to)
}

public func ~<E: FlowOutProtocol, M: InOutProtocol>(out: JoinView<E, M>, to: @escaping @Sendable Out) -> any OutJoinProtocol {
    OutJoin(out.0, to)
}

