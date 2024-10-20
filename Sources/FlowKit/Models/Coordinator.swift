//
//  Coordinator.swift
//  
//
//  Created by Gerardo Grisolini on 07/02/23.
//

// Global events store
var eventStore = EventStore()

/// Coordinator is the object that manages the flow
final class Coordinator<Flow: FlowProtocol>: CoordinatorProtocol {
	@Injected private var navigation: NavigationProtocol
    private var model: Flow.Model?
    let flow: Flow
    let parent: (any FlowViewProtocol)?

    init(flow: Flow, parent: (any FlowViewProtocol)? = nil) {
        self.flow = flow
        self.parent = parent
 	}

    private func getOut(_ event: some FlowOutProtocol) -> Out? {
        guard let out = flow.behavior.outs.first(where: { $0.from.id == event.id }) else { return nil }
        return out.to
    }

    private func getEvent(_ event: some FlowEventProtocol) -> Event? {
        guard let event = flow.behavior.events.first(where: { $0.from.id == event.id }) else { return nil }
        return event.to
    }

    func start(model: Flow.CoordinatorNode.View.In, navigate: Bool = true) async throws {
        try await show(node: flow.node, model: model, navigate: navigate)
    }

    private func parseJoin(_ join: any CoordinatorJoinProtocol, _ data: any InOutProtocol) async throws {
        if let route = join.node as? any Routable {
            try await navigation.flow(route: route).start(model: data, parent: parent)
        } else if let node = join.node as? any CoordinatorNodeProtocol {
            try await show(node: node, model: data)
        }
    }
    
    private func show(node: any CoordinatorNodeProtocol, model m: some InOutProtocol, navigate: Bool = true) async throws {
        let view = navigate ? try await node.view.factory(model: m) : parent!
        if navigate {
            navigation.navigate(view: view)
        }

        for try await event in await view.events {
            switch event {
            case .back:
                navigation.pop()

            case .next(let next):
                let data = next.associated.value ?? InOutEmpty()
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
                    await view.onEventChange(event: event, model: view.model)
                    continue
                }
                let model = try await flowEvent(event)
                await view.onEventChange(event: event, model: model)

            case .commit(let m, let toRoot):
                guard let model = m as? Flow.Model else {
                    throw FlowError.invalidModel(String(describing: Flow.Model.self))
                }
                await parent?.onCommit(model: model)
                guard toRoot else {
                    navigation.popToFlow()
                    continue
                }
                navigation.popToRoot()

            case .navigate(let view):
                navigation.navigate(view: view)

            case .present(let view):
                navigation.present(view: view)
            }
		}

        await eventStore.remove(view.id)
    }
}

/// CoordinatorEvent is the enum of events that the coordinator can handle
public enum CoordinatorEvent {
    case back
    case next(any FlowOutProtocol)
    case commit(any InOutProtocol, toRoot: Bool)
    case event(any FlowEventProtocol)

    case present(any Presentable)
    case navigate(any Navigable)
}

/// InOutEmpty is the empty inout model
public final class InOutEmpty: InOutProtocol {
    public init() { }
}
public final class InOutNotEmpty: InOutProtocol {
    public init() { }
}

/// EventEmpty is the empty event
public enum EventBase: FlowEventProtocol {
    case commit
}

/// OutEmpty is the empty out event
public enum OutEmpty: FlowOutProtocol { }
