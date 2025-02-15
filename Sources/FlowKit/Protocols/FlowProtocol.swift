//
//  FlowProtocol.swift
//  FlowKit
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
    func start(parent: (any FlowViewProtocol)?, navigate: Bool) async throws

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
