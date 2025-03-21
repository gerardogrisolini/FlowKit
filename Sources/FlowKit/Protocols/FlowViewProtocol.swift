//
//  FlowViewProtocol.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 10/03/24.
//

import SwiftUI
import NavigationKit

/// FlowEventProtocol is the protocol for the action events
public protocol FlowEventProtocol: Nodable, CaseIterable { }

/// FlowOutProtocol is the protocol for the navigation events
public protocol FlowOutProtocol: FlowEventProtocol { }

/// FlowViewProtocol is the protocol for the flow view
public protocol FlowViewProtocol: Sendable {
    associatedtype In: InOutProtocol
    associatedtype Out: FlowOutProtocol = OutEmpty
    associatedtype Event: FlowEventProtocol = EventBase

    /// The model for the view
    var model: In { get }
    /// AsyncSequence for manage the events
    var events: AsyncThrowingSubject<CoordinatorEvent> { get }
    /// Init the view with model
    @MainActor init(model: In)
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

    /// Parse enum of events from view and widget
    /// - Parameters:
    /// - event: the widget event
    /// - Returns: the view event
    func parse(_ event: any FlowEventProtocol) throws -> any FlowEventProtocol {
        guard let parsed = Event.allCases.first(where: { $0.id == event.id}) else {
            throw FlowError.partialMapping(String(describing: event))
        }
        guard let associated = event.associated.value else {
            return parsed
        }
        return parsed.udpate(associatedValue: associated)
    }

    /// Parse enum of outs from view and widget
    /// - Parameters:
    /// - event: the widget out
    /// - Returns: the view out
    func parse(_ out: any FlowOutProtocol) throws -> any FlowOutProtocol {
        guard let parsed = Out.allCases.first(where: { $0.id == out.id}) else {
            throw FlowError.partialMapping(String(describing: out))
        }
        guard let associated = out.associated.value else {
            return parsed
        }
        return parsed.udpate(associatedValue: associated)
    }

    /// Implementation of factory function to create the view
    /// - Parameters:
    /// - model: the input model
    /// - Returns: the view
    static func factory(model: some InOutProtocol) async throws -> Self {
        guard let m = model as? Self.In else {
            throw FlowError.invalidModel("\(model)".id)
        }
        return await Self(model: m)
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
    /// - mode: presentation mode
    func present(_ mode: PresentMode) {
        events.send(.present(mode))
    }

    /// Navigate to view
    /// - Parameters:
    /// - view: the view to navigate
    func navigate(_ view: RouteView) {
        events.send(.navigate(view))
    }
}

/// FlowViewEmpty is the empty flow view
@FlowView(InOutEmpty.self)
public struct FlowViewEmpty: View, FlowViewProtocol {
    public var body: some View { EmptyView() }
}
