//
//  EventsBuilder.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 20/02/24.
//

import SwiftUI

public protocol EventJoinProtocol {
    associatedtype Key: FlowEventProtocol

    var from: Key { get }
    var to: Event { get }
}

public struct EventJoin<T: FlowEventProtocol>: EventJoinProtocol {
    public let from: T
    public let to: Event

    public init(_ from: T, _ to: @escaping @Sendable Event) {
        self.from = from
        self.to = to
    }
}

@resultBuilder
public enum EventsBuilder {
    public static func buildBlock() -> [any EventJoinProtocol] { [] }

    public static func buildBlock(_ components: (any EventJoinProtocol)...) -> [any EventJoinProtocol]  {
        components
    }

    public static func buildBlock(_ components: [any EventJoinProtocol]...) -> [any EventJoinProtocol]  {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[any EventJoinProtocol]]) -> [any EventJoinProtocol]  {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: any EventJoinProtocol) -> [any EventJoinProtocol] {
        [expression]
    }

    public static func buildOptional(_ components: [any EventJoinProtocol]?) -> [any EventJoinProtocol]  {
        components ?? []
    }

    public static func buildEither(first components: [any EventJoinProtocol]) -> [any EventJoinProtocol]  {
        components
    }

    public static func buildEither(second components: [any EventJoinProtocol]) -> [any EventJoinProtocol]  {
        components
    }

    public static func buildPartialBlock(first: [any EventJoinProtocol]) -> [any EventJoinProtocol] {
        first
    }

    public static func buildPartialBlock(accumulated: [any EventJoinProtocol], next: [any EventJoinProtocol]) -> [any EventJoinProtocol] {
        accumulated + next
    }
}

infix operator ~
public func ~<T: FlowEventProtocol>(from: T, to: @escaping @Sendable Event) -> any EventJoinProtocol {
    EventJoin(from, to)
}

public func ~<E: FlowEventProtocol, M: InOutProtocol>(out: JoinView<E, M>, to: @escaping @Sendable Event) -> any EventJoinProtocol {
    EventJoin(out.0, to)
}
