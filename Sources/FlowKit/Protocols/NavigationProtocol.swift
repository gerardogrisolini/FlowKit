//
//  NavigationProtocol.swift
// 
//
//  Created by Gerardo Grisolini on 11/10/22.
//

import Combine

/// Navigable is the protocol that a view or flow must implement to be navigable
public protocol Navigable: Sendable { }

/// Nodable is the protocol that must implement to be nodable
public protocol Nodable: Sendable {
    associatedtype Model: InOutProtocol
    var model: Model.Type { get }
}

/// Routable is the protocol that a view or flow must implement to be routable
public protocol Routable: Nodable { }

/// NavigationProtocol is the protocol for manage the navigation
@MainActor
public protocol NavigationProtocol: AnyObject, Sendable {

    /// The subscriber of actions for the navigation
    var action: PassthroughSubject<NavigationAction, Never> { get }

    /// The routes stack of navigation pages
    var routes: [String] { get set }

    /// The items for the routes of the navigation
    var items: NavigationItems { get set }

	init()

    /// Register a route with a view
    /// - Parameters:
    ///  - route: the route to register
    ///  - with: the closure to create the view
    func register(route: some Routable, with: @escaping @Sendable () -> (any Navigable))

    /// Get a flow with a route
    /// - Parameters:
    /// - route: the route to register
    /// - Returns: the flow
	func flow(route: some Routable) throws -> (any FlowProtocol)

    /// Navigate to a route string
    /// - Parameters:
    /// - routeString: the route string to navigate
    func navigate(routeString: String)

    /// Present a route string
    /// - Parameters:
    /// - routeString: the route string to present
    func present(routeString: String)

    /// Navigate to a view
    /// - Parameters:
    /// - view: the view to navigate
    func navigate(view: some Navigable)

    /// Present a view
    /// - Parameters:
    /// - view: the view to present
	func present(view: some Presentable)

    /// Navigate to a route
    /// - Parameters:
    /// - route: the route to navigate
    func navigate(route: some Routable) throws

    /// Present a route
    /// - Parameters:
    /// - route: the route to present
    func present(route: some Routable) throws

    /// Pop the current route
	func pop()

    /// Pop to the beginning of the flow
    func popToFlow()

    /// Pop to the root of the navigation
    func popToRoot()

    /// Dismiss the presented view
	func dismiss()
}

public extension Navigable {

    /// The route string for the navigable
    var routeString: String {
        String(describing: type(of: self))
    }
}

public extension Routable {
    
    var model: InOutEmpty.Type { InOutEmpty.self }
}
