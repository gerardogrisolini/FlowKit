//
//  FlowWidgetProtocol.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 05/10/24.
//

import SwiftUI
import NavigationKit

/// FlowWidgetProtocol is the protocol for the widget of flow view
@MainActor public protocol FlowWidgetProtocol {
    associatedtype Out: FlowOutProtocol = OutEmpty
    associatedtype Event: FlowEventProtocol = EventBase

    /// The parent of the widget
    var parent: any FlowViewProtocol { get }
}

private struct ParentKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: any FlowViewProtocol = FlowViewEmpty()
}

public extension EnvironmentValues {
    var parent: any FlowViewProtocol {
        get { self[ParentKey.self] }
        set { self[ParentKey.self] = newValue }
    }
}

public extension FlowWidgetProtocol {
    /// Navigate back
    func back() {
        parent.back()
    }

    /// Navigate to next view
    /// - Parameters:
    /// - event: the event
    func out(_ event: Out) {
        do {
            let next = try parent.parse(event)
            parent.events.send(.next(next))
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
        parent.commit(model, toRoot: toRoot)
    }

    /// Present a view
    /// - Parameters:
    /// - mode: presentation mode
    func present(_ mode: PresentMode) {
        parent.events.send(.present(mode))
    }

    /// Navigate to view
    /// - Parameters:
    /// - view: the view to navigate
    func navigate(_ view: RouteView) {
        parent.events.send(.navigate(view))
    }
}
