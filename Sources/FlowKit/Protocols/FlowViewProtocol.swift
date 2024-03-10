//
//  FlowViewProtocol.swift
//  
//
//  Created by Gerardo Grisolini on 10/03/24.
//

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
    /// - Parameters:
    /// - model: the input model
    /// - Returns: the view
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
    /// - Parameters:
    /// - event: the event
    /// - model: the model
    func onEventChanged(_ event: Event, _ model: (any InOutProtocol)?) async { }

    /// Implementation of test function
    /// - Parameters:
    /// - event: the event
    func test(event: Event) async throws {
        await onEventChanged(event, nil)
    }

    /// Navigate back
    func back() {
        events.send(.back)
    }

    /// Navigate to next view
    /// - Parameters:
    /// - event: the event
    func out(_ event: Out) {
        events.send(.next(event))
    }

    /// Execute an event
    /// - Parameters:
    /// - event: the event
    func event(_ event: Event) {
        events.send(.event(event))
    }

    /// Commit the model and popToFlow or popToRoot
    /// - Parameters:
    /// - model: the model to commit
    /// - toRoot: if true pop to root
    func commit(_ model: some InOutProtocol, toRoot: Bool = false) {
        events.send(.commit(model, toRoot: toRoot))
    }

    /// Present a view
    /// - Parameters:
    /// - view: the view to present
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
    /// The id of the event
    var id: String {
        String(describing: self).className
    }

    /// Associated value of the event
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
