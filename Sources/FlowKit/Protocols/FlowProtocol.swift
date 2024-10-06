//
//  FlowProtocol.swift
//
//
//  Created by Gerardo Grisolini on 28/01/23.
//

import SwiftUI
import Resolver

/// FlowError is the error type for the flow
public enum FlowError: Error {
    case generic, routeNotFound, flowNotFound, eventNotFound, invalidModel(String), partialMapping(String)
}

/// FlowRouteProtocol is the protocol for the automatic route registration
@objc public protocol FlowRouteProtocol { }

/// FlowProtocol is the main protocol for the flow
public protocol FlowProtocol: FlowRouteProtocol, Navigable {
    associatedtype Route: Routable
    associatedtype CoordinatorNode: CoordinatorNodeProtocol
    associatedtype Model: InOutProtocol
    associatedtype Behavior: FlowBehaviorProtocol

    /// The route of the flow
    static var route: Route { get }
    /// The return model of the flow
    var model: Model { get }
    /// The entry node of the flow
    var node: CoordinatorNode { get }
    /// The behavior of the flow
    var behavior: Behavior { get }

    init()

    /// Function performed before the flow starts
    func onStart(model: some InOutProtocol) async throws -> any InOutProtocol
    /// Function to start the flow with a model
    @discardableResult func start(model: some InOutProtocol, parent: (any FlowViewProtocol)?) async throws
}

public extension FlowProtocol {
    /// Default flow behavior
    var behavior: FlowBehavior { .init() }

    /// Default flow return model
    public var model: InOutEmpty { .init() }

    /// Default implementation for the onStart function
    /// - Parameters:
    /// - model: the input model
    /// - Returns: the output model
    func onStart(model: some InOutProtocol) async throws -> any InOutProtocol {
        model
    }

    /// Default implementation for the start function with a model
    /// - Parameters:
    /// - model: the input model
    /// - Returns: the output model
    func start(model: some InOutProtocol, parent: (any FlowViewProtocol)? = nil) async throws {
        let m = try await onStart(model: model)

        guard let m = m as? CoordinatorNode.View.In else {
            let modelName = String(describing: m)
            throw FlowError.invalidModel(modelName)
        }

        Resolver
            .register { self.behavior }
            .implements(FlowBehaviorProtocol.self)
            .scope(.shared)

        try await Coordinator(flow: self, parent: parent).start(model: m)
    }

    /// Function to test the flow
    func test() async throws {
        try testNode(node: node)
    }

    /// Function to test the node
    private func testNode(node: any Nodable) throws {
        switch node {
        case let n as any CoordinatorNodeProtocol:
            guard n.eventsCount == n.joins.count else {
                throw FlowError.partialMapping(String(describing: n.view))
            }

            let modelClassName = (n.view as! any FlowViewProtocol).model.className
            for join in n.joins {
                let className = join.event.associated.value?.className ?? modelClassName
                if let node = join.node as? any CoordinatorNodeProtocol {
                    try node.validate(className: className)
                    try testNode(node: node)
                }
            }
        default: break
        }
    }
}

