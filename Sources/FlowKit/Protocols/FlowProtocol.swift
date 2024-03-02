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

    /// The route for the flow
    static var route: Route { get }
    /// The return model for the flow
    var model: Model { get set }
    /// The entry node for the flow
    var node: CoordinatorNode { get }
    /// The behavior for the flow
    var behavior: Behavior { get }

    init()
    /// Function performed before the flow starts
    func onStart(model: some InOutProtocol) async throws -> any InOutProtocol
    /// Function to start the flow with a model
    @discardableResult func start(model: some InOutProtocol) async throws -> Model
    /// Function to start the flow without a model
    @discardableResult func start() async throws -> Model
}

public extension FlowProtocol {
    /// Default implementation for the behavior
    var behavior: FlowBehavior { FlowBehavior() }

    /// Default implementation for the onStart function
    func onStart(model: some InOutProtocol) async throws -> any InOutProtocol {
        model
    }

    /// Default implementation for the start function with a model
    func start(model: some InOutProtocol) async throws -> Model {
        let m = try await onStart(model: model)

        guard let m = m as? CoordinatorNode.View.In else {
            let modelName = String(describing: m)
            throw FlowError.invalidModel(modelName)
        }

        Resolver
            .register { self.behavior }
            .implements(FlowBehaviorProtocol.self)
            .scope(.shared)

        return try await Coordinator(flow: self).start(model: m)
    }

    /// Default implementation for the start function without a model
    func start() async throws -> Model {
        let model = CoordinatorNode.View.In()
        return try await start(model: model)
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

            for join in n.joins {
                let model = join.event.associated.value ?? n.in.init()
                if let node = join.node as? any CoordinatorNodeProtocol {
                    try node.validate(model: model)
                    try testNode(node: node)
                }
            }
        default: break
        }
    }
}

/// IdentifiableCase is the protocol for the identifiable cases
public protocol IdentifiableCase: Hashable, Equatable, Identifiable { }
/// InOutProtocol is the protocol for the input/output model
public protocol InOutProtocol: AnyObject, IdentifiableCase {
    init()
}
/// FlowEventProtocol is the protocol for the action events
public protocol FlowEventProtocol: IdentifiableCase { }
/// FlowOutProtocol is the protocol for the navigation events
public protocol FlowOutProtocol: FlowEventProtocol, CaseIterable { }

/// FlowViewProtocol is the protocol for the flow view
public protocol FlowViewProtocol: Navigable {
    associatedtype In: InOutProtocol
    associatedtype Out: FlowOutProtocol = OutEmpty
    associatedtype Event: FlowEventProtocol = EventEmpty

    /// AsyncSequence for manage the events
    var events: AsyncThrowingSubject<CoordinatorEvent> { get }
    /// The model for the view
    var model: In { get }
    /// Init the view with the model
    init(model: In)

    /// Factory function to create the view
    static func factory(model: some InOutProtocol) throws -> Self
    /// Function to handle the event change
    func onEventChanged(_ event: Event, _ model: (any InOutProtocol)?) async
}

public extension FlowViewProtocol {
    /// The id of the flow view
    var id: String { "\(self)".className }

    /// Implementation of events injected from a EventStore
    var events: AsyncThrowingSubject<CoordinatorEvent> {
        guard let event = eventStore[id] else {
            let newEvent = AsyncThrowingSubject<CoordinatorEvent>()
            eventStore[id] = newEvent
            return newEvent
        }
        return event
    }

    /// Implementation of factory function to create the view
    static func factory(model: some InOutProtocol) throws -> Self {
        guard let m = model as? Self.In else {
            throw FlowError.invalidModel(String(describing: model))
        }
        return Self(model: m)
    }

    /// Function to handle the event change internally
    internal func onEventChange(_ event: any FlowEventProtocol, _ model: (any InOutProtocol)?) async {
        guard let e = event as? Event else { return }
        await onEventChanged(e, model)
    }

    /// Default implementation of function to handle the event change
    func onEventChanged(_ event: Event, _ model: (any InOutProtocol)?) async { }

    /// Implementation of test function
    func test(event: Event) async throws {
        await onEventChanged(event, nil)
    }

    /// Function to navigate back
    func back() {
        events.send(.back)
    }

    /// Function to navigate to next view
    func out(_ event: Out) {
        events.send(.next(event))
    }

    /// Function to execute an event
    func event(_ event: Event) {
        events.send(.event(event))
    }

    /// Function to commit the model and popToFlow or popToRoot
    func commit(_ model: some InOutProtocol, toRoot: Bool = false) {
        events.send(.commit(model, toRoot: toRoot))
    }

    /// Function to present a view
    func present(_ view: some Presentable) {
        events.send(.present(view))
    }
}

public extension IdentifiableCase {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension FlowEventProtocol {
    var id: String {
        String(describing: self).className
    }

    var associated: (label: String, value: (any InOutProtocol)?) {
        let mirror = Mirror(reflecting: self)
        guard let associated = mirror.children.first else {
            return ("\(self)", nil)
        }
        return (associated.label!, associated.value as? any InOutProtocol)
    }
}

public extension String {
    var id: String {
        var data = self
        if let start = self.lastIndex(of: ".") {
            let index = data.index(start, offsetBy: 1)
            data = String(data.suffix(from: index))
        }
        return data.className
    }

    var className: String {
        guard let index = firstIndex(of: "(") else {
            return self
        }
        let end = self.index(index, offsetBy: -1)
        return String(prefix(through: end))
    }
}
