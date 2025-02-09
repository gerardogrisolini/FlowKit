//
//  RouterProtocol.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

import Combine

/// RouterProtocol is the protocol for manage the navigation
@MainActor @preconcurrency public protocol RouterProtocol: AnyObject, Sendable {

    /// The subscriber of actions for the navigation
    var action: PassthroughSubject<RouterAction, Never> { get }

    /// The routes stack of navigation pages
    var routes: [String] { get set }

    /// The items for the routes of the navigation
    var items: RouterItems { get set }

    /// The presentation mode of the navigation
    var presentMode: PresentMode? { get set }

    /// Register a route with a view
    /// - Parameters:
    ///  - route: the route to register
    ///  - with: the closure to create the view
    func register(route: some Routable, with: @escaping @MainActor @Sendable () -> (any Sendable))

    /// Navigate to a route string
    /// - Parameters:
    /// - routeString: the route string to navigate
    func navigate(routeString: String)

    /// Navigate to a view
    /// - Parameters:
    /// - view: the view to navigate
    func navigate(view: any Sendable)

    /// Navigate to a route
    /// - Parameters:
    /// - route: the route to navigate
    func navigate(route: some Routable) throws

    /// Present a view
    /// - Parameters:
    /// - mode: Presentation mode
    func present(_ mode: PresentMode)

    /// Pop the current route
    func pop()

    /// Pop to the beginning of the flow
    func popToFlow()

    /// Pop to the root of the navigation
    func popToRoot()

    /// Dismiss the presented view
    func dismiss()
}
