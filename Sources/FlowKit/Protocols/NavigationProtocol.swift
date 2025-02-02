//
//  NavigationProtocol.swift
// 
//
//  Created by Gerardo Grisolini on 11/10/22.
//

import SwiftUI
import Combine

/// Nodable is the protocol that must implement to be nodable
public protocol Nodable: Identifiable, Sendable {

    associatedtype Model: InOutProtocol
    var model: Model.Type { get }

    func udpate(associatedValue: some InOutProtocol) -> Self
}

/// Routable is the protocol that a view or flow must implement to be routable
public protocol Routable: Nodable, CaseIterable { }

/// NavigationProtocol is the protocol for manage the navigation
@MainActor @preconcurrency public protocol NavigationProtocol: AnyObject, Sendable {

    /// The subscriber of actions for the navigation
    var action: PassthroughSubject<NavigationAction, Never> { get }

    /// The routes stack of navigation pages
    var routes: [String] { get set }

    /// The items for the routes of the navigation
    var items: NavigationItems { get set }

    /// The presentation mode of the navigation
    var presentMode: PresentMode? { get set }

    /// Register a route with a view
    /// - Parameters:
    ///  - route: the route to register
    ///  - with: the closure to create the view
    func register(route: some Routable, with: @escaping @MainActor @Sendable () -> (any Sendable))

    /// Register a route and parameter with a view
    /// - Parameters:
    ///  - route: the route to register
    ///  - with: the closure to create the view
    func register<R: Routable, M: InOutProtocol>(route: JoinRoute<R, M>, with: @escaping @MainActor @Sendable (M) -> (any Sendable))

    /// Get a flow with a route
    /// - Parameters:
    /// - route: the route to register
    /// - Returns: the flow
    func flow(route: some Routable) throws -> (any FlowProtocol)

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

/// Alert action for confirmation dialog
public struct AlertAction: Sendable {

    public enum Style: Int, Sendable {
        case `default` = 0
        case cancel = 1
        case destructive = 2
    }

    public let title: String
    public let style: Style
    public let handler: @MainActor @Sendable () -> Void

    public init(title: String, style: Style, handler: @escaping @MainActor @Sendable () -> Void) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

public enum PresentationDetents: Sendable {
    /// The system detent for a sheet that's approximately half the height of
    /// the screen, and is inactive in compact height.
    case medium

    /// The system detent for a sheet at full height.
    case large

    /// A custom detent with the specified fractional height.
    case fraction(_ fraction: CGFloat)

    /// A custom detent with the specified height.
    case height(_ height: CGFloat)
}

public extension View {

    /// The route string for the navigable
    var routeString: String {
        String(describing: type(of: self))
    }
}

#if canImport(UIKit)
import UIKit

public extension UIViewController {

    /// The route string for the navigable
    var routeString: String {
        String(describing: type(of: self))
    }
}
#endif

public extension Routable {

    /// The route string for the navigable
    var routeString: String {
        "\(associated.label) - \(associated.value?.className ?? "InOutEmpty")"
    }

    /// Associated value of the route
    var associated: (label: String, value: (any InOutProtocol)?) {
        let mirror = Mirror(reflecting: self)
        guard let associated = mirror.children.first else {
            return ("\(self)", nil)
        }
        return (associated.label!, associated.value as? any InOutProtocol)
    }
}


/// Dependency injection for navigation
private struct NavigationProviderKey: @preconcurrency InjectionKey {
    @MainActor static var currentValue: NavigationProtocol = NavigationSwiftUI()
}

public extension InjectedValues {
    var navigation: NavigationProtocol {
        get { Self[NavigationProviderKey.self] }
        set { Self[NavigationProviderKey.self] = newValue }
    }
}
