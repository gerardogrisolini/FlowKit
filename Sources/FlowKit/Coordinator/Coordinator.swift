//
//  Coordinator.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 07/02/23.
//

import Foundation
import NavigationKit

/// The `Coordinator` class is responsible for managing the flow of a specific feature or module in an application.
/// It orchestrates navigation, event handling, and data passing between views and flow nodes.
/// This class operates in the main actor context for UI-related safety and synchronization.
final class Coordinator<Flow: FlowProtocol>: CoordinatorProtocol {

    /// The flow associated with the coordinator, defining the behavior and structure of the feature.
    let flow: Flow

    /// The parent view that adheres to the `FlowViewProtocol`. It acts as the context for the current coordinator.
    let parent: (any FlowViewProtocol)?

    /// The router handler used to manage transitions and route handling.
    private var router: RouterProtocol

    /// The model associated with the current flow. This may hold shared or contextual data.
    private var model: Flow.Model?

    /// Initializes a `Coordinator` instance with the given flow, parent view, and optional navigation handler.
    /// - Parameters:
    ///   - flow: The flow to be managed by the coordinator.
    ///   - parent: The parent view, if applicable.
    ///   - navigation: An optional custom navigation handler. Defaults to a resolved instance.
    init(flow: Flow, parent: (any FlowViewProtocol)? = nil, router: RouterProtocol? = nil) {
        self.flow = flow
        self.parent = parent
        self.router = router ?? InjectedValues[\.router]
    }

    /// Starts the coordinator by initializing and displaying the flow's root node.
    /// - Parameter navigate: A flag indicating whether navigation should occur. Defaults to `true`.
    /// - Throws: An error if the flow cannot be started.
    func start(navigate: Bool = true) async throws {
        let model = router.items.getParam(for: Flow.route.routeString) ?? InOutEmpty()
        try await show(node: flow.node, model: model, navigate: navigate)
    }

    /// Parses and processes a join operation within the flow.
    /// - Parameters:
    ///   - join: The join operation conforming to `CoordinatorJoinProtocol`.
    ///   - data: The data associated with the join operation.
    /// - Throws: An error if the join cannot be processed.
    private func parseJoin(_ join: any CoordinatorJoinProtocol, _ data: any InOutProtocol) async throws {
        if let r = join.node as? any Routable {
            let route = r.udpate(associatedValue: data)
            try await router.flow(route: route).start(parent: parent, navigate: true)
        } else if let node = join.node as? any CoordinatorNodeProtocol {
            try await show(node: node, model: data)
        }
    }

    /// Displays a specific node within the coordinator's flow.
    /// - Parameters:
    ///   - node: The node to be displayed, conforming to `CoordinatorNodeProtocol`.
    ///   - model: The data model to be passed to the node.
    ///   - navigate: A flag indicating whether navigation should occur. Defaults to `true`.
    /// - Throws: An error if the node cannot be displayed.
    private func show(node: any CoordinatorNodeProtocol, model m: some InOutProtocol, navigate: Bool = true) async throws {
        let view = navigate ? try await node.view.factory(model: m) : parent!
        if navigate {
            router.navigate(view: view)
        }

        for try await event in view.events {
            do {
                switch event {
                case .back:
                    router.pop()

                case .next(let next):
                    guard let join = node.joins.first(where: { next.id == $0.event.id }) else {
                        throw FlowError.eventNotFound
                    }
                    switch try await flow.runOut(next) {
                    case .model(let m):
                        try await parseJoin(join, m)
                    case .node(let n, let m):
                        try await show(node: n, model: m)
                    }

                case .event(let event):
                    let model = try await flow.runEvent(event)
                    await view.onEventChange(event: event, model: model)

                case .commit(let m, let toRoot):
                    guard let model = m as? Flow.Model else {
                        throw FlowError.invalidModel(String(describing: Flow.Model.self))
                    }
                    await parent?.onCommit(model: model)
                    guard toRoot else {
                        router.popToFlow()
                        continue
                    }
                    router.popToRoot()

                case .navigate(let view):
                    router.navigate(view: view)

                case .present(let mode):
                    router.present(mode)
                }

            } catch {
                print(error)
                router.present(.toast(message: "\(error)", style: .error))
                continue
            }
        }
    }
}

/// `CoordinatorEvent` defines the possible events that the `Coordinator` can handle.
/// These events are triggered by the flow or user interaction.
public enum CoordinatorEvent: Sendable {
    case back
    case next(any FlowOutProtocol)
    case commit(any InOutProtocol, toRoot: Bool)
    case event(any FlowEventProtocol)

    case present(_ mode: PresentMode)
    case navigate(any Sendable)
}

/// `EventBase` defines a basic flow event with a predefined set of actions.
public enum EventBase: FlowEventProtocol {
    case commit
}

/// `OutEmpty` serves as a placeholder for cases where no output event is defined.
/// It conforms to the `FlowOutProtocol` for compatibility.
public enum OutEmpty: FlowOutProtocol { }
