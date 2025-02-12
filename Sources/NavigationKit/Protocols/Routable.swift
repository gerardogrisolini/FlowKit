//
//  Routable.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

/// **RouteView: Typealias for a Routable View**
///
/// - Represents a **SwiftUI view** that conforms to `Sendable`.
/// - The `any Sendable` constraint ensures **thread safety** for concurrent environments.
/// - The optional `?` allows flexibility where a route **may not have an associated view**.
public typealias RouteView = (any Sendable)?

/// **Routable Protocol: Defines a Navigable Route**
///
/// This protocol must be implemented by **views or flows** to be navigable within `NavigationKit`.
///
/// - **Extends `Nodable`**:
///   - Ensures each route is **identifiable and concurrency-safe**.
/// - **Extends `CaseIterable`**:
///   - Allows enumeration of all available routes, useful for **defining route lists**.
/// - **Defines `view` Property**:
///   - Every routable entity must specify an **associated SwiftUI view**.
///
/// ## Example Usage:
/// ```swift
/// enum AppRoutes: String, Routable {
///     case home, profile, settings
///
///     var view: RouteView {
///         switch self {
///         case .home: return HomeView()
///         case .profile: return ProfileView()
///         case .settings: return SettingsView()
///         }
///     }
/// }
/// ```
public protocol Routable: Nodable, CaseIterable {

    /// **Associated View of the Route**
    ///
    /// - Specifies the **SwiftUI view** associated with the route.
    /// - Must be accessed from the **main thread** (`@MainActor`).
    /// - Can return `nil` if the route **does not have a corresponding view**.
    @MainActor var view: RouteView { get }
}
