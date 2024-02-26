//
//  Coordinator.swift
//  
//
//  Created by Gerardo Grisolini on 07/02/23.
//

import Foundation

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

var eventStore = EventStore()

public final class Coordinator<Flow: FlowProtocol>: CoordinatorProtocol {
	@LazyInjected private var navigation: NavigationProtocol
    public var flow: Flow

	public init(flow: Flow) {
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

    public func start(model: Flow.CoordinatorNode.View.In) async throws -> Flow.Model {
        try await show(node: flow.node, model: model)
        return flow.model
    }

    private func parseJoin(_ join: any CoordinatorJoinProtocol, _ data: (any InOutProtocol)) async throws {
        if let route = join.node as? any Routable {
            let flow = try navigation.flow(route: route)
            try await show(node: flow.node, model: data)
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
                    view.onEventChange(event, nil)
                    continue
                }
                let model = try await flowEvent(event)
                view.onEventChange(event, model)

            case .present(let view):
                navigation.present(view: view)
                
            case .commit(let m):
                guard let model = m as? Flow.Model else {
                    throw FlowError.invalidModel(String(describing: Flow.Model.self))
                }
                flow.model = model
                navigation.popToRoot()
            }
		}

        eventStore.remove(view.id)
    }
}

public enum CoordinatorEvent {
    case back
    case next(any FlowOutProtocol)
	case present(any Presentable)
	case commit(any InOutProtocol)
    case event(any FlowEventProtocol)
}

public final class InOutEmpty: InOutProtocol { 
    public init() { }
}

public enum OutEmpty: FlowOutProtocol {
    public static var allCases: [EventEmpty] { [] }
}

public enum EventEmpty: FlowEventProtocol { }
