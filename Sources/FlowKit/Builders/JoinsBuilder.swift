//
//  JoinsBuilder.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 06/02/24.
//

import SwiftUI
import NavigationKit

@resultBuilder
public enum JoinsBuilder {
    public static func buildBlock() -> [any CoordinatorJoinProtocol] { [] }

    public static func buildBlock(_ components: (any CoordinatorJoinProtocol)...) -> [any CoordinatorJoinProtocol]  {
        components
    }

    public static func buildBlock(_ components: [any CoordinatorJoinProtocol]...) -> [any CoordinatorJoinProtocol]  {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[any CoordinatorJoinProtocol]]) -> [any CoordinatorJoinProtocol]  {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: any CoordinatorJoinProtocol) -> [any CoordinatorJoinProtocol] {
        [expression]
    }

    public static func buildOptional(_ components: [any CoordinatorJoinProtocol]?) -> [any CoordinatorJoinProtocol]  {
        components ?? []
    }

    public static func buildEither(first components: [any CoordinatorJoinProtocol]) -> [any CoordinatorJoinProtocol]  {
        components
    }

    public static func buildEither(second components: [any CoordinatorJoinProtocol]) -> [any CoordinatorJoinProtocol]  {
        components
    }

    public static func buildPartialBlock(first: [any CoordinatorJoinProtocol]) -> [any CoordinatorJoinProtocol] {
        first
    }

    public static func buildPartialBlock(accumulated: [any CoordinatorJoinProtocol], next: [any CoordinatorJoinProtocol]) -> [any CoordinatorJoinProtocol] {
        accumulated + next
    }
}

public extension FlowViewProtocol {
    static var node: Node<Self> {
        Node(Self.self)
    }

    static func node(@JoinsBuilder _ content: (Self.Out.Type) -> [any CoordinatorJoinProtocol]) -> Node<Self> {
        Node(Self.self, content(Self.Out.self))
    }
}

infix operator ~
public func ~<Out: FlowOutProtocol, Node: Nodable>(out: Out, node: Node) -> any CoordinatorJoinProtocol where Node.Model == InOutEmpty {
    Join(out, node)
}

public typealias JoinView<E: FlowEventProtocol, M: InOutProtocol> = (E, M)

public func ~<E: FlowOutProtocol, M: InOutProtocol, Node: Nodable>(out: JoinView<E, M>, node: Node) -> any CoordinatorJoinProtocol where M == Node.Model {
    Join(out.0, node)
}

public func ~<E: FlowOutProtocol, R: Routable, M: InOutProtocol>(out: JoinView<E, M>, node: JoinRoute<R, M>) -> any CoordinatorJoinProtocol {
    Join(out.0, node.0)
}
