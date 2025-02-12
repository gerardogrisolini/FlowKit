//
//  RouterProtocol.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

import Combine

/// **RouterProtocol: Defines Navigation Management**
///
/// This protocol provides an abstraction for handling navigation within `NavigationKit`.
/// It ensures a **structured approach to routing**, allowing navigation between views and managing presentation modes.
///
/// - Conforms to `AnyObject` to enforce **class-only adoption**.
/// - Conforms to `Sendable` to ensure **thread safety**.
/// - Uses `@MainActor` to ensure **all navigation actions are performed on the main thread**.
@MainActor @preconcurrency public protocol RouterProtocol: AnyObject, Sendable {

    /// **Action Publisher for Navigation Events**
    ///
    /// - A `PassthroughSubject` that emits `RouterAction` events.
    /// - Allows listening to navigation-related actions and responding accordingly.
    ///
    /// ## Example:
    /// ```swift
    /// router.action.send(.navigate("home"))
    /// ```
    var action: PassthroughSubject<RouterAction, Never> { get }

    /// **Stack of Active Routes**
    ///
    /// - Holds an array of route strings representing the navigation stack.
    /// - Used to track the current navigation history.
    var routes: [String] { get set }

    /// **Dictionary of Registered Routes**
    ///
    /// - Contains mappings between route identifiers and corresponding views.
    /// - Allows dynamic view registration and retrieval based on route strings.
    var items: RouterItems { get set }

    /// **Presentation Mode State**
    ///
    /// - Stores the current **presentation mode** (e.g., modal, sheet, full-screen cover).
    /// - This helps manage different types of navigation presentations.
    var presentMode: PresentMode? { get set }

    /// **Register a Route with a View**
    ///
    /// - Allows dynamic registration of a `Routable` entity with an associated view.
    /// - Uses a closure to lazily create the view when needed.
    ///
    /// - Parameters:
    ///   - route: A `Routable` instance representing the navigation route.
    ///   - page: A closure that returns a SwiftUI view conforming to `Sendable`.
    ///
    /// ## Example:
    /// ```swift
    /// router.register(route: HomeRoute()) {
    ///     HomeView()
    /// }
    /// ```
    func register(route: some Routable, for page: @escaping @MainActor @Sendable () -> (any Sendable))

    /// **Navigate to a Route String**
    ///
    /// - Allows navigation using a route string identifier.
    ///
    /// - Parameter routeString: The **string identifier** of the destination route.
    ///
    /// ## Example:
    /// ```swift
    /// router.navigate(routeString: "profile")
    /// ```
    func navigate(routeString: String)

    /// **Navigate to a Specific View**
    ///
    /// - Navigates directly to a SwiftUI `View` conforming to `Sendable`.
    ///
    /// - Parameter view: The view instance to be navigated to.
    ///
    /// ## Example:
    /// ```swift
    /// router.navigate(view: ProfileView())
    /// ```
    func navigate(view: any Sendable)

    /// **Navigate to a `Routable` Route**
    ///
    /// - Provides type-safe navigation using a `Routable` instance.
    /// - Throws an error if navigation fails.
    ///
    /// - Parameter route: The `Routable` instance representing the destination.
    ///
    /// ## Example:
    /// ```swift
    /// try router.navigate(route: AppRoutes.profile)
    /// ```
    func navigate(route: some Routable) throws

    /// **Present a View in a Specific Mode**
    ///
    /// - Displays a view using a `PresentMode` (e.g., sheet, full-screen cover).
    ///
    /// - Parameter mode: The **presentation mode** to use for the view.
    ///
    /// ## Example:
    /// ```swift
    /// router.present(.sheet(ProfileView()))
    /// ```
    func present(_ mode: PresentMode)

    /// **Pop the Current Route**
    ///
    /// - Removes the topmost route from the navigation stack.
    ///
    /// ## Example:
    /// ```swift
    /// router.pop()
    /// ```
    func pop()

    /// **Pop to the Root Route**
    ///
    /// - Clears the navigation stack, returning to the **root view**.
    ///
    /// ## Example:
    /// ```swift
    /// router.popToRoot()
    /// ```
    func popToRoot()

    /// **Dismiss the Currently Presented View**
    ///
    /// - Closes any currently presented modal or sheet.
    ///
    /// ## Example:
    /// ```swift
    /// router.dismiss()
    /// ```
    func dismiss()
}
