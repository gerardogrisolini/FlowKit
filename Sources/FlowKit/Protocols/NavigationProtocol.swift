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
@MainActor
public protocol NavigationProtocol: AnyObject, Sendable {

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
    func register(route: some Routable, with: @escaping @Sendable (any InOutProtocol) -> (any Sendable)) async

    /// Register a route and parameter with a view
    /// - Parameters:
    ///  - route: the route to register
    ///  - with: the closure to create the view
    func register<R: Routable, M: InOutProtocol>(route: JoinRoute<R, M>, with: @escaping @Sendable (M) -> (any Sendable)) async

    /// Get a flow with a route
    /// - Parameters:
    /// - route: the route to register
    /// - Returns: the flow
	func flow(route: some Routable) throws -> (any FlowProtocol)

    /// Navigate to a route string
    /// - Parameters:
    /// - routeString: the route string to navigate
    func navigate(routeString: String) async

    /// Navigate to a view
    /// - Parameters:
    /// - view: the view to navigate
    func navigate(view: any Sendable) async

    /// Navigate to a route
    /// - Parameters:
    /// - route: the route to navigate
    func navigate(route: some Routable) async throws

    /// Present a view
    /// - Parameters:
    /// - mode: Presentation mode
    func present(_ mode: PresentMode)

    /// Pop the current route
	func pop() async

    /// Pop to the beginning of the flow
    func popToFlow() async

    /// Pop to the root of the navigation
    func popToRoot() async

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
    public let handler: @Sendable () -> Void
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

/// Presentation modes
public enum PresentMode: Identifiable, Sendable, Equatable {
    case alert(title: String = "", message: String = "")
    case confirmationDialog(title: String = "", actions: [AlertAction])
    case sheet(any Sendable, detents: [PresentationDetents] = [.medium, .large])
    case fullScreenCover(any Sendable)

    public var id: String { "\(self)" }

    var routeString: String? {
        switch self {
        case .alert, .confirmationDialog: return nil
        case .sheet(let view, let detents): return "sheet-\(view)-\(String(describing: detents))"
        case .fullScreenCover(let view): return "fullScreenCover-\(view)"
        }
    }

    public static func == (lhs: PresentMode, rhs: PresentMode) -> Bool {
        lhs.id == rhs.id
    }
}

public extension View {

    /// The route string for the navigable
    var routeString: String {
        String(describing: type(of: self))
    }

    /// Dismiss presented view
    var dismiss: () -> () {
        Resolver.resolve(NavigationProtocol.self).dismiss
    }
}

#if canImport(UIKit)
import UIKit

public extension UIViewController {

    /// The route string for the navigable
    var routeString: String {
        String(describing: self)
    }
}
#endif

public extension Routable {

    /// The route string for the navigable
    var routeString: String {
        let text = String(describing: self)
        return text //"\(text.className)-\(text)"
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
