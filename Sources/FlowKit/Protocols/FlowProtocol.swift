//
//  FlowProtocol.swift
//
//
//  Created by Gerardo Grisolini on 28/01/23.
//

import SwiftUI

/// FlowError is the error type for the flow
public enum FlowError: Error {
    case generic, routeNotFound, flowNotFound, eventNotFound, invalidModel(String), partialMapping(String)
}

/// FlowRouteProtocol is the protocol for the automatic route registration
@objc public protocol FlowRouteProtocol { }

/// FlowProtocol is the main protocol for the flow
public protocol FlowProtocol: FlowRouteProtocol, Sendable where RouteModel == CoordinatorNode.View.In {
    associatedtype Route: Routable
    associatedtype RouteModel: InOutProtocol
    associatedtype CoordinatorNode: CoordinatorNodeProtocol
    associatedtype Model: InOutProtocol
    associatedtype Behavior: FlowBehaviorProtocol

    /// The route of the flow
    static var route: Route { get }
    /// The return model of the flow
    var node: CoordinatorNode { get }
    /// The behavior of the flow
    var behavior: Behavior { get }

    init()

    /// Function to start the flow with a model
    func start(parent: (any FlowViewProtocol)?) async throws
}

public extension FlowProtocol {
    /// Default flow behavior
    var behavior: FlowBehavior { .init() }

    /// Default implementation for the start function with a model
    /// - Parameters:
    /// - parent: the parent page
    /// - Returns: the output model
    func start(parent: (any FlowViewProtocol)? = nil) async throws {
        await MainActor.run {
            InjectedValues[\.flowBehavior] = behavior
        }
        try await Coordinator(flow: self, parent: parent).start()
    }

    /// Function to test the flow
    func test(route: Route) async throws {
        var m = route.associated.value?.className ?? "InOutEmpty"
        if let index = m.lastIndex(of: ".") {
            m = String(m.suffix(from: m.index(after: index)))
        }
        guard m == String(describing: node.model) else {
            throw FlowError.invalidModel(m)
        }
        try testNode(node: node)
    }

    /// Function to test the node
    private func testNode(node: any Nodable) throws {
        switch node {
        case let n as any CoordinatorNodeProtocol:
            guard n.eventsCount == n.joins.count else {
                throw FlowError.partialMapping(String(describing: n.view))
            }

            var className = "\(n.model)".className
            for join in n.joins {
                if let value = join.event.associated.value {
                    className = "\(value)".id
                }
                if let node = join.node as? any CoordinatorNodeProtocol {
                    try node.validate(className: className)
                    try testNode(node: node)
                }
            }
        default: break
        }
    }
}

