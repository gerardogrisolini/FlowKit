//
//  CoordinatorNode.swift
//  
//
//  Created by Gerardo Grisolini on 07/02/23.
//

/// Join is the struct that links the event with the node
public struct Join<Out: FlowOutProtocol, Node: Nodable>: CoordinatorJoinProtocol {
    public let event: Out
    public let node: Node

    public init(_ event: Out, _ node: Node) {
        self.event = event
        self.node = node
    }
}

/// Node is the struct that links the pages of a flow
public struct Node<View: FlowViewProtocol>: CoordinatorNodeProtocol {

    public let view: View.Type
    public var model: View.In.Type { View.In.self }
    public var joins: [any CoordinatorJoinProtocol] = []
    public var eventsCount: Int { view.Out.allCases.count }

    public init(_ view: View.Type) {
        self.view = view
    }

    public init(_ view: View.Type, _ joins: [any CoordinatorJoinProtocol]) {
        self.init(view)
        self.joins = joins
    }

//    public init(_ view: View.Type, _ joins: [View.Out: any Nodable]) {
//        self.init(view)
//        self.joins = joins.map { Join($0.key, $0.value) }
//    }

//    public static func ~>(_ node: Self, _ joins: [Self.View.Out: any Nodable] = [:]) -> Self {
//        var node = node
//        node.joins = joins.map { Join($0.key, $0.value) }
//        return node
//    }
}
