//
//  FlowWidgetProtocol.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 05/10/24.
//

import SwiftUI

/// FlowWidgetProtocol is the protocol for the widget of flow view
public protocol FlowWidgetProtocol {
    associatedtype Out: FlowOutProtocol = OutEmpty
    associatedtype Event: FlowEventProtocol = EventBase

    /// The parent of the widget
    var parent: any FlowViewProtocol { get }
}

public extension EnvironmentValues {
    @Entry var parent: any FlowViewProtocol = FlowViewEmpty()
}

public extension FlowWidgetProtocol {
    /// Navigate back
    func back() {
        parent.events.send(.back)
    }

    /// Navigate to next view
    /// - Parameters:
    /// - event: the event
    /// - model: the model
    func out(_ event: Out, model: some InOutProtocol = InOutEmpty()) {
        do {
            let next = try parent.parse(event)
            parent.events.send(.next(next, model))
        } catch {
            print(error)
        }
    }

    /// Execute an event
    /// - Parameters:
    /// - event: the event
    func event(_ event: Event) {
        do {
            let e = try parent.parse(event)
            parent.events.send(.event(e))
        } catch {
            print(error)
        }
    }

    /// Commit the model and popToFlow or popToRoot
    /// - Parameters:
    /// - model: the model to commit
    /// - toRoot: if true pop to root
    func commit(_ model: some InOutProtocol, toRoot: Bool = false) {
        parent.events.send(.commit(model, toRoot: toRoot))
    }

    /// Present a view
    /// - Parameters:
    /// - view: the view to present
    func present(_ view: some Presentable) {
        parent.events.send(.present(view))
    }

    /// Navigate to view
    /// - Parameters:
    /// - view: the view to navigate
    func navigate(_ view: some Navigable) {
        parent.events.send(.navigate(view))
    }
}
