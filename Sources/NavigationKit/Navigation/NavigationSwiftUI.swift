//
//  NavigationSwiftUI.swift
//
//
//  Created by Gerardo Grisolini on 11/10/22.
//

import SwiftUI
import Combine

/// A navigation handler designed for SwiftUI, providing a declarative navigation system.
/// It manages navigation actions and routes using Combine and a route-based approach.
open class NavigationSwiftUI: NavigationProtocol {

    /// A publisher that sends navigation-related actions, allowing reactive handling of navigation.
    public let action = PassthroughSubject<NavigationAction, Never>()

    /// Stores the list of active routes in the navigation stack.
    public var routes: [String] = []

    /// Stores navigation items mapped to their respective routes.
    public var items = NavigationItems()

    /// Stores the current presentation mode (e.g., modal, sheet, full-screen).
    public var presentMode: PresentMode? = nil

    /// Initializes an instance of `NavigationSwiftUI`.
    public init() { }

    /// Navigates to a specified route string by appending it to the navigation stack.
    /// - Parameter routeString: The string identifier for the navigation route.
    public func navigate(routeString: String) {
        routes.append(routeString)
        action.send(.navigate(routeString))
    }

    /// Navigates using a `Routable` object, ensuring the route exists before navigating.
    /// - Parameter route: The route conforming to `Routable`.
    /// - Throws: `NavigationError.routeNotFound` if the route is not found in `items`.
    public func navigate(route: some Routable) throws {
        let routeString = route.routeString
        guard items.setParam(for: routeString, param: route.associated.value) else {
            throw NavigationError.routeNotFound
        }
        navigate(routeString: routeString)
    }

    /// Removes a specific route from the navigation stack.
    /// - Parameter route: The route string to be removed.
    open func removeRoute(_ route: String) {
        items.remove(route)
    }

    /// Pops the top view from the navigation stack.
    /// This removes the last route and sends a `.pop` action.
    public func pop() {
        if let route = routes.popLast() {
            removeRoute(route)
            action.send(.pop(route))
        }
    }

    /// Pops all view controllers until it reaches the starting point of a navigation flow.
    /// This iterates through the stack, removing routes and sending `.pop` actions.
    open func popToFlow() {
        while let route = routes.popLast() {
            removeRoute(route)
            action.send(.pop(route))
        }
    }

    /// Pops all view controllers and returns to the root view.
    /// This clears the entire navigation stack and sends a `.popToRoot` action.
    public func popToRoot() {
        while let route = routes.popLast() {
            removeRoute(route)
        }
        action.send(.popToRoot)
    }

    /// Dismisses the currently presented modal or sheet.
    /// If a modal is active, it removes the associated route and resets `presentMode`.
    public func dismiss() {
        if let _ = presentMode {
            action.send(.dismiss)

            if let routeString = presentMode?.routeString {
                routes.removeAll(where: { $0 == routeString })
            }
            presentMode = nil
        }
    }
}
