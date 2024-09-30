//
//  FlowViewProtocol.swift
//  
//
//  Created by Gerardo Grisolini on 10/03/24.
//

import SwiftUI

/// IdentifiableCase is the protocol for the identifiable cases
public protocol IdentifiableCase: Hashable, Equatable, Identifiable { }

/// InOutProtocol is the protocol for the input/output model
public protocol InOutProtocol: Identifiable {
    init()
}
/// FlowEventProtocol is the protocol for the action events
public protocol FlowEventProtocol: IdentifiableCase { }

/// FlowOutProtocol is the protocol for the navigation events
public protocol FlowOutProtocol: FlowEventProtocol, CaseIterable { }

/// FlowViewProtocol is the protocol for the flow view
public protocol FlowViewProtocol<In>: Navigable {
    associatedtype In: InOutProtocol
    associatedtype Out: FlowOutProtocol = OutEmpty
    associatedtype Event: FlowEventProtocol = EventBase

    /// AsyncSequence for manage the events
    var events: AsyncThrowingSubject<CoordinatorEvent> { get }
    /// The model for the view
    @MainActor @preconcurrency var model: In { get set }

    /// Init the view with the model
    @MainActor @preconcurrency init()

    /// Factory function to create the view
    static func factory(model: some InOutProtocol) async throws -> Self
    /// Function to handle the event change
    func onEventChanged(event: Event, model: some InOutProtocol) async
    /// Function to handle the commit
    func onCommit(model: some InOutProtocol) async
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
    static func factory(model: some InOutProtocol) async throws -> Self {
        guard let m = model as? Self.In else {
            throw FlowError.invalidModel(String(describing: model))
        }
        var obj = await Self()
        await MainActor.run {
            obj.model = m
        }
        return obj
    }

    /// Function to handle the event change internally
    internal func onEventChange(event: some FlowEventProtocol, model: some InOutProtocol) async {
        guard let e = event as? Event else { return }
        await onEventChanged(event: e, model: model)
    }
    
    /// Default implementation of function to handle the event change
    /// - Parameters:
    /// - event: the event
    /// - model: the model
    func onEventChanged(event: Event, model: some InOutProtocol) async { }

    /// Default implementation of function to handle the commit event
    /// - Parameters:
    /// - model: the model
    func onCommit(model: some InOutProtocol) async { }

    /// Implementation of test function
    /// - Parameters:
    /// - event: the event
    func test(event: Event) async throws {
        await onEventChanged(event: event, model: InOutEmpty())
    }
    
    /// Navigate back
    func back() {
        events.send(.back)
    }
    
    /// Navigate to next view
    /// - Parameters:
    /// - event: the event
    func out(_ event: Out) {
        events.send(.next(event, model))
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

    /// Navigate to view
    /// - Parameters:
    /// - view: the view to navigate
    func navigate(_ view: some Navigable) {
        events.send(.navigate(view))
    }
}

public extension View where Self: FlowViewProtocol {
    /// Join a view with the flow
    /// - Parameters:
    /// - flow: the flow to join
    /// - Returns: the view
    func join<F: FlowProtocol>(flow: F) -> some View {
        swiftUINavigation()
            .task {
                do {
                    try await Coordinator(flow: flow, parent: self)
                        .start(model: flow.node.in.init(), navigate: false)
                } catch {
                    print("Error on joining flow: \(error)")
                }
            }
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
