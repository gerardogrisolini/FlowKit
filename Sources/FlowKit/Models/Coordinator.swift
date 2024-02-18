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

    private var commands: [AnyHashable: Command] {
        (flow as? FlowBehaviorProtocol)?.behavior.commands ?? [:]
    }

	public init(flow: Flow) {
        self.flow = flow
 	}

    private func getCommand(_ event: some FlowEventProtocol) -> Command? {
        let key = event as AnyHashable
        guard commands.contains(where: { $0.key == key }) else { return nil }
        return commands[key]
    }

    public func start(model: Flow.CoordinatorNode.View.In) async throws -> Flow.Model {
        try await show(node: flow.node, model: model)
        return flow.model
    }

    //@MainActor
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

                guard let command = getCommand(next) else {
                    if let route = join.node as? any Routable {
                        let flow = try navigation.flow(route: route)
                        try await show(node: flow.node, model: data)
                    } else {
                        try await show(node: join.node as! any CoordinatorNodeProtocol, model: data)
                    }
                    continue
                }
                
                switch try await command(data) {
                case .model(let m):
                    try await show(node: join.node as! any CoordinatorNodeProtocol, model: m)

                case .node(let n, let m):
                    try await show(node: n, model: m)
                }
                
            case .event(let event):
                view.onEventChange(event)

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
    case next(any FlowEventProtocol)
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
