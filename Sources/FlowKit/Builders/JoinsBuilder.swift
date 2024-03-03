//
//  JoinsBuilder.swift
//
//
//  Created by Gerardo Grisolini on 06/02/24.
//

import SwiftUI

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
public func ~<Out: FlowOutProtocol, Node: Nodable>(out: Out, node: Node) -> any CoordinatorJoinProtocol {
    Join(out, node)
}

//let flow = EmptyFlowView.node {
//    $0.empty ~ EmptyFlowView.node
//    for i in 0...5 {
//        $0.empty ~ EmptyFlowView.node
//    }
//    $0.empty ~ EmptyFlowView.node {
//        $0.empty ~ EmptyFlowView.node
//    }
//}
//
//public struct EmptyFlowView: FlowViewProtocol, View {
//    public enum Out: FlowOutProtocol {
//        case empty
//    }
//    public let model: InOutEmpty
//    public init(model: InOutEmpty = InOutEmpty()) {
//        self.model = model
//    }
//
//    public var body: some View {
//        EmptyView()
//    }
//}
