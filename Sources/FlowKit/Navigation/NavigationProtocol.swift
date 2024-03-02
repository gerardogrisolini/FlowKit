//
//  NavigationProtocol.swift
// 
//
//  Created by Gerardo Grisolini on 11/10/22.
//

#if canImport(UIKit)
import UIKit
#endif
import Combine

/// Navigable is the protocol that a view or flow must implement to be navigable
public protocol Navigable { }

/// Nodable is the protocol that must implement to be nodable
public protocol Nodable { }

/// Routable is the protocol that a view or flow must implement to be routable
public protocol Routable: Nodable, RawRepresentable { }

/// NavigationProtocol is the protocol for manage the navigation
public protocol NavigationProtocol: AnyObject {

#if canImport(UIKit)
    /// The navigation controller for UIKit
    var navigationController: UINavigationController? { get set }
#endif

    /// The subscriber of actions for the navigation
    var action: PassthroughSubject<NavigationAction, Never> { get }

    /// The routes stack of navigation pages
	var routes: [String] { get set }

    /// The items for the routes of the navigation
    var items: [String: () -> (any Navigable)] { get set }

    /// The dismiss action for the navigation
    var onDismiss: (() -> ())? { get set }
	
	init()

    /// Function to register a route with a view
	func register(route: some Routable, with: @escaping () -> (any Navigable))

    /// Function to register a route with a flow
	func flow(route: some Routable) throws -> (any FlowProtocol)

    /// Function to navigate to a route
    func navigate(routeString: String)

    /// Function to present a route
    func present(routeString: String)

    /// Function to navigate to a view
    func navigate(view: some Navigable)

    /// Function to present a view
	func present(view: some Presentable)

    /// Function to navigate to a route
    func navigate(route: some Routable) throws

    /// Function to present a route
    func present(route: some Routable) throws

    /// Function to pop the current route
	func pop()

    /// Function to pop to a route
    func popToView(routeString: String)

    /// Function to pop to the root of the navigation
    func popToRoot()

    /// Function to dismiss the presented view
	func dismiss()
}
