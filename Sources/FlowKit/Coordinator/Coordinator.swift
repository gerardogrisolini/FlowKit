//
//  Coordinator.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 07/02/23.
//

import Foundation
import NavigationKit

/// The `Coordinator` class manages the flow of a specific feature or module in an application.
/// It orchestrates navigation, event handling, and data passing between views and flow nodes.
/// This class operates in the main actor context for UI-related safety and synchronization.
final class Coordinator<Flow: FlowProtocol>: CoordinatorProtocol {

    /// The flow associated with the coordinator, defining the behavior and structure of the feature.
    let flow: Flow

    /// The parent view acting as the context for the current coordinator.
    let parent: (any FlowViewProtocol)?

    /// The router handler used to manage transitions and route handling.
    private let router: RouterProtocol

    /// The model associated with the current flow.
    private var model: Flow.Model?

    /// Initializes a `Coordinator` instance.
    init(flow: Flow, parent: (any FlowViewProtocol)? = nil, router: RouterProtocol? = nil) {
        self.flow = flow
        self.parent = parent
        self.router = router ?? InjectedValues[\.router]
    }

    /// Starts the coordinator by initializing and displaying the flow's root node.
    func start(navigate: Bool = true) async throws {
        let model = router.items.getParam(for: Flow.route.routeString) ?? InOutEmpty()
        try await show(node: flow.node, model: model, navigate: navigate)
    }

    /// Parses and processes a join operation within the flow.
    private func parseJoin(_ join: any CoordinatorJoinProtocol, _ data: any InOutProtocol) async throws {
        if let routableNode = join.node as? any Routable {
            let route = routableNode.udpate(associatedValue: data)
            try await router.flow(route: route).start(parent: parent, navigate: true)
        } else if let node = join.node as? any CoordinatorNodeProtocol {
            try await show(node: node, model: data)
        }
    }

    /// Displays a specific node within the coordinator's flow.
    private func show(node: any CoordinatorNodeProtocol, model: some InOutProtocol, navigate: Bool = true) async throws {
        let view = navigate ? try await node.view.factory(model: model) : parent!
        if navigate {
            router.navigate(view: view)
        }

        for try await event in view.events {
            do {
                try await handleEvent(event, node: node, view: view)
            } catch {
                handleError(error)
            }
        }
    }

    /// Handles various events triggered by the flow or user interaction.
    private func handleEvent(_ event: CoordinatorEvent, node: any CoordinatorNodeProtocol, view: any FlowViewProtocol) async throws {
        switch event {
        case .back:
            router.pop()

        case .next(let next):
            try await handleNextEvent(next, node: node)

        case .event(let event):
            let model = try await flow.runEvent(event)
            await view.onEventChange(event: event, model: model)

        case .commit(let model, let toRoot):
            try await handleCommitEvent(model, toRoot: toRoot)

        case .navigate(let view):
            router.navigate(view: view)

        case .present(let mode):
            router.present(mode)
        }
    }

    /// Handles the "next" event, transitioning to a new node or executing an output action.
    private func handleNextEvent(_ next: any FlowOutProtocol, node: any CoordinatorNodeProtocol) async throws {
        guard let join = node.joins.first(where: { next.id == $0.event.id }) else {
            throw FlowError.eventNotFound
        }

        switch try await flow.runOut(next) {
        case .model(let model):
            try await parseJoin(join, model)
        case .node(let newNode, let model):
            try await show(node: newNode, model: model)
        }
    }

    /// Handles the "commit" event, updating the parent and managing navigation.
    private func handleCommitEvent(_ model: any InOutProtocol, toRoot: Bool) async throws {
        guard let validModel = model as? Flow.Model else {
            throw FlowError.invalidModel(String(describing: Flow.Model.self))
        }

        await parent?.onCommit(model: validModel)
        toRoot ? router.popToRoot() : router.popToFlow()
    }

    /// Handles errors gracefully, presenting a toast notification.
    private func handleError(_ error: Error) {
        print("Error: \(error)")
        router.present(.toast(message: "\(error)", style: .error))
    }
}

/// Defines possible events handled by the `Coordinator`.
public enum CoordinatorEvent: Sendable {
    case back
    case next(any FlowOutProtocol)
    case commit(any InOutProtocol, toRoot: Bool)
    case event(any FlowEventProtocol)
    case present(_ mode: PresentMode)
    case navigate(RouteView)
}

/// Defines a basic flow event with predefined actions.
public enum EventBase: FlowEventProtocol {
    case commit
}

/// Serves as a placeholder when no output event is defined.
public enum OutEmpty: FlowOutProtocol { }
