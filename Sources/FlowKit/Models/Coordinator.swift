//
//  Coordinator.swift
//  
//
//  Created by Gerardo Grisolini on 07/02/23.
//

import Foundation

/// EventStore is the pages events store
struct EventStore {
    private var events = Dictionary<String, AsyncThrowingSubject<CoordinatorEvent>>()
    subscript(key: String) -> AsyncThrowingSubject<CoordinatorEvent>? {
        get { events[key] }
        set { events[key] = newValue }
    }
    mutating func remove(_ key: String) {
        events.removeValue(forKey: key)
    }
}

// Global events store
var eventStore = EventStore()

/// Coordinator is the object that manages the flow
final class Coordinator<Flow: FlowProtocol>: CoordinatorProtocol {
	@Injected private var navigation: NavigationProtocol
    var flow: Flow

	init(flow: Flow) {
        self.flow = flow
 	}

    private func getOut(_ event: some FlowOutProtocol) -> Out? {
        guard let out = flow.behavior.outs.first(where: { $0.from.id == event.id }) else { return nil }
        return out.to
    }

    private func getEvent(_ event: some FlowEventProtocol) -> Event? {
        guard let event = flow.behavior.events.first(where: { $0.from.id == event.id }) else { return nil }
        return event.to
    }

    func start(model: Flow.CoordinatorNode.View.In) async throws -> Flow.Model {
        navigation.routes.append("\(Flow.route)")
        try await show(node: flow.node, model: model)
        return flow.model
    }

    private func parseJoin(_ join: any CoordinatorJoinProtocol, _ data: (any InOutProtocol)) async throws {
        if let route = join.node as? any Routable {
            try await navigation.flow(route: route).start(model: data)
        } else if let node = join.node as? any CoordinatorNodeProtocol {
            try await show(node: node, model: data)
        }
    }
    
    @MainActor
    private func show(node: any CoordinatorNodeProtocol, model: some InOutProtocol) async throws {
        let view = try node.view.factory(model: model)
		navigation.navigate(view: view)

        for try await event in view.events {
            switch event {
            case .back:
                navigation.pop()

            case .next(let next):
                let data = next.associated.value ?? view.model

                guard let join = node.joins.first(where: { next.id == $0.event.id }) else {
                    throw FlowError.eventNotFound
                }

                guard let out = getOut(next) else {
                    try await parseJoin(join, data)
                    continue
                }

                switch try? await out(data) {
                case .model(let m):
                    try await parseJoin(join, m)
                case .node(let n, let m):
                    try await show(node: n, model: m)
                case .none:
                    continue
                }
                
            case .event(let event):
                guard let flowEvent = getEvent(event) else {
                    await view.onEventChange(event, nil)
                    continue
                }
                let model = try await flowEvent(event)
                await view.onEventChange(event, model)

            case .present(let view):
                navigation.present(view: view)
                
            case .commit(let m, let toRoot):
                guard let model = m as? Flow.Model else {
                    throw FlowError.invalidModel(String(describing: Flow.Model.self))
                }
                flow.model = model
                guard toRoot else {
                    navigation.popToFlow()
                    continue
                }
                navigation.popToRoot()
            }
		}

        eventStore.remove(view.id)
    }
}

/// CoordinatorEvent is the enum of events that the coordinator can handle
public enum CoordinatorEvent {
    case back
    case next(any FlowOutProtocol)
	case present(any Presentable)
    case commit(any InOutProtocol, toRoot: Bool)
    case event(any FlowEventProtocol)
}

/// InOutEmpty is the empty inout model
public final class InOutEmpty: InOutProtocol {
    public init() { }
}

/// OutEmpty is the empty out event
public enum OutEmpty: FlowOutProtocol {
    public static var allCases: [EventEmpty] { [] }
}

/// EventEmpty is the empty event
public enum EventEmpty: FlowEventProtocol { }
