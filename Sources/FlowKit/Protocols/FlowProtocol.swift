//
//  FlowProtocol.swift
//
//
//  Created by Gerardo Grisolini on 28/01/23.
//

import SwiftUI

public enum FlowError: Error {
    case generic, routeNotFound, flowNotFound, eventNotFound, invalidModel(String), partialMapping(String)
}

@objc public protocol FlowRouteProtocol { }

public protocol FlowProtocol: FlowRouteProtocol, Navigable {
    associatedtype CoordinatorNode: CoordinatorNodeProtocol
    associatedtype Model: InOutProtocol
    associatedtype Route: Routable
    var model: Model { get set }
    var node: CoordinatorNode { get }
    static var route: Route { get }

    init()
    func onStart(model: some InOutProtocol) async throws -> any InOutProtocol
    @discardableResult func start(model: some InOutProtocol) async throws -> Model
    @discardableResult func start() async throws -> Model
}

public extension FlowProtocol {
    func onStart(model: some InOutProtocol) async throws -> any InOutProtocol {
        model
    }

    func start(model: some InOutProtocol) async throws -> Model {
        let m = try await onStart(model: model)
        guard let m = m as? CoordinatorNode.View.In else {
            let modelName = String(describing: m)
            throw FlowError.invalidModel(modelName)
        }
        return try await Coordinator(flow: self).start(model: m)
    }

    func start() async throws -> Model {
        let model = CoordinatorNode.View.In()
        return try await start(model: model)
    }

    func test() async throws {
        try testNode(node: node)
    }

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

public protocol IdentifiableCase: Hashable, Equatable, Identifiable { }
public protocol InOutProtocol: AnyObject, IdentifiableCase {
    init()
}
public protocol FlowEventProtocol: IdentifiableCase { }
public protocol FlowOutProtocol: FlowEventProtocol, CaseIterable { }

public protocol FlowViewProtocol: Navigable {
    associatedtype In: InOutProtocol
    associatedtype Out: FlowOutProtocol = OutEmpty
    associatedtype Event: FlowEventProtocol = EventEmpty

    var events: AsyncThrowingSubject<CoordinatorEvent> { get }
    var model: In { get }
    init(model: In)

    static func factory(model: some InOutProtocol) throws -> Self
    func onEventChanged(_ event: Event)
}

public extension FlowViewProtocol {
    var id: String { "\(self)".className }

    var events: AsyncThrowingSubject<CoordinatorEvent> {
        guard let event = eventStore[id] else {
            let newEvent = AsyncThrowingSubject<CoordinatorEvent>()
            eventStore[id] = newEvent
            return newEvent
        }
        return event
    }

    static func factory(model: some InOutProtocol) throws -> Self {
        guard let m = model as? Self.In else {
            throw FlowError.invalidModel(String(describing: model))
        }
        return Self(model: m)
    }

    internal func onEventChange(_ event: any FlowEventProtocol) {
        guard let e = event as? Event else { return }
        onEventChanged(e)
    }

    func onEventChanged(_ event: Event) { }

    func test(event: Event) async throws {
        onEventChanged(event)
    }

//    static func node(_ content: [Self.Out: any Nodable]) -> Node<Self> {
//        Node(Self.self, content)
//    }

    func back() {
        events.send(.back)
    }

    func out(_ event: Out) {
        events.send(.next(event))
    }

    func event(_ event: Event) {
        events.send(.event(event))
    }

    func commit(_ model: some InOutProtocol) {
        events.send(.commit(model))
    }

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
