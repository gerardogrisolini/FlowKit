//
//  FlowProtocol.swift
//
//
//  Created by Gerardo Grisolini on 28/01/23.
//

import SwiftUI
import NavigationKit

/// Results is the enum that contains the Out function result
public enum Results: Sendable {
    case model(any InOutProtocol)
    case node(any CoordinatorNodeProtocol, any InOutProtocol)
//    case route(any Routable, any InOutProtocol)
}

public typealias Out = (any InOutProtocol) async throws -> Results
public typealias Event = (any FlowEventProtocol) async throws -> any InOutProtocol

/// FlowRouteProtocol is the protocol for the automatic route registration
@objc public protocol FlowRouteProtocol { }

/// FlowProtocol is the main protocol for the flow
public protocol FlowProtocol: FlowRouteProtocol, Sendable where RouteModel == CoordinatorNode.View.In {
    associatedtype Route: Routable
    associatedtype RouteModel: InOutProtocol
    associatedtype CoordinatorNode: CoordinatorNodeProtocol
    associatedtype Model: InOutProtocol

    /// The route of the flow
    static var route: Route { get }
    /// The return model of the flow
    var node: CoordinatorNode { get }

    init()

    /// Starting flow with the parent
    /// - Parameters:
    /// - parent: the parent page
    /// - Returns: the output model
    func start(parent: (any FlowViewProtocol)?) async throws

    /// Executes an event within the flow and returns the resulting input/output model.
    /// - Parameter event: An instance conforming to `FlowEventProtocol`, representing the event to be executed.
    /// - Returns: An instance conforming to `InOutProtocol`, representing the outcome of the event.
    /// - Throws: An error if the event cannot be executed or processed.
    func runEvent(_ event: any FlowEventProtocol) async throws -> any InOutProtocol

    /// Executes an outgoing flow operation and returns the result.
    /// - Parameter out: An instance conforming to `FlowOutProtocol`, representing the outgoing operation to execute.
    /// - Returns: A `Results` enumeration value containing either the model or the node produced by the operation.
    /// - Throws: An error if the operation cannot be executed or the result cannot be determined.
    func runOut(_ out: any FlowOutProtocol) async throws -> Results
}

public extension FlowProtocol {

    func start(parent: (any FlowViewProtocol)? = nil) async throws {
        try await Coordinator(flow: self, parent: parent).start()
    }

    func runEvent(_ event: any FlowEventProtocol) async throws -> any InOutProtocol {
        event.associated.value ?? InOutEmpty()
    }

    func runOut(_ out: any FlowOutProtocol) async throws -> Results {
        .model(out.associated.value ?? InOutEmpty())
    }

    /// Tests the specified route to ensure its associated value and the node's model match.
    /// - Parameter route: An instance conforming to `Route`, representing the route to be tested.
    /// - Throws: A `FlowError.invalidModel` error if the class name of the route's associated value
    /// does not match the class name of the flow's node model.
    /// Additionally, propagates any error thrown by the `testNode(node:)` method.
    func test(route: Route) async throws {
        // Extract the class name from the associated value of the route, defaulting to "InOutEmpty" if nil.
        var m = route.associated.value?.className ?? "InOutEmpty"

        // Remove any namespace or module prefix from the class name, leaving only the base class name.
        if let index = m.lastIndex(of: ".") {
            m = String(m.suffix(from: m.index(after: index)))
        }

        // Ensure the extracted class name matches the class name of the node's model.
        guard m == String(describing: node.model) else {
            throw FlowError.invalidModel(m) // Throw an error if there is a mismatch.
        }

        // Test the node structure to ensure that all events and joins are properly mapped and validated.
        try testNode(node: node)
    }

    /// Tests the given node to ensure that all its events and joins are correctly mapped and validated.
    /// - Parameter node: An instance conforming to `Nodable`, representing the node to be tested.
    /// - Throws: A `FlowError.partialMapping` if the number of events does not match the joins,
    /// or if any associated value or node validation fails during testing.
    private func testNode(node: any Nodable) throws {
        switch node {
        case let n as any CoordinatorNodeProtocol:
            // Ensure the number of events matches the number of joins
            guard n.eventsCount == n.joins.count else {
                throw FlowError.partialMapping(String(describing: n.view))
            }

            // Retrieve the class name of the node's model
            var className = "\(n.model)".className

            // Iterate over each join to validate the node and its associated values
            for join in n.joins {
                if let value = join.event.associated.value {
                    className = "\(value)".id
                }
                if let node = join.node as? any CoordinatorNodeProtocol {
                    // Validate the node's class name and recursively test its child nodes
                    try node.validate(className: className)
                    try testNode(node: node)
                }
            }
        default:
            break // No action for non-CoordinatorNodeProtocol conforming nodes
        }
    }
}

