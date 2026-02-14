//
//  Router+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 22/02/23.
//

/// A typealias for defining a route with an associated model.
/// - `R`: A `Routable` type representing the route.
/// - `M`: An `InOutProtocol` type representing the data model passed to the route.
public typealias JoinRoute<R: Routable, M: InOutProtocol> = (R, M)

public extension RouterProtocol {

    /// Registers a route that requires a parameterized model.
    ///
    /// - Parameters:
    ///   - route: A `JoinRoute` containing the route and its associated model.
    ///   - page: A closure that returns a navigable view when provided with the model.
    ///
    /// - The function extracts the `routeString` from the `Routable` instance.
    /// - It registers a closure that takes a parameter (`param`) and passes it to the page function.
    /// - If the parameter cannot be cast to `M`, it falls back to the model provided during registration.
    func register<R: Routable, M: InOutProtocol>(route: JoinRoute<R, M>, for page: @escaping @MainActor @Sendable (M) -> (RouteView)) {
        let routeString = route.0.routeString
        items.setValue(for: routeString, value: { param in
            guard let model = param as? M else {
                assertionFailure("Invalid model type for route \(routeString). Expected \(M.self), got \(type(of: param)).")
                return page(route.1)
            }
            return page(model)
        }, registered: true)
    }

    /// Registers a route that does not require a parameter.
    ///
    /// - Parameters:
    ///   - route: A `Routable` representing the route.
    ///   - page: A closure that returns a navigable view without requiring a model.
    ///
    /// - Extracts `routeString` from the `Routable` instance.
    /// - Registers a closure that simply returns the view when invoked.
    func register(route: some Routable, for page: @escaping @MainActor @Sendable () -> (RouteView)) {
        let routeString = route.routeString
        items.setValue(for: routeString, value: { _ in page() }, registered: true)
    }

    /// Navigates to a view by dynamically registering it.
    ///
    /// - Parameters:
    ///   - view: The view to navigate to, conforming to `Sendable`.
    ///
    /// - The function derives a `routeString` based on the view's type.
    /// - Registers the view under this route string in `items`.
    /// - Calls `navigate(routeString:)` to push the route into the navigation stack.
    func navigate(view: RouteView) {
        let routeString = String(describing: type(of: view))
        items.setValue(for: routeString, value: { _ in view })
        navigate(routeString: routeString)
    }

    /// Presents a view in a specific presentation mode (e.g., modal, full screen).
    ///
    /// - Parameters:
    ///   - mode: The presentation mode, defined in `PresentMode`.
    ///
    /// - Updates the `presentMode` state.
    /// - If the `PresentMode` contains a route string, it appends it to `routes`.
    /// - Sends a `.present(mode)` action to trigger the UI update.
    func present(_ mode: PresentMode) {
        presentMode = mode

        if let route = mode.routeString {
            routes.append(route)
        }
        action.send(.present(mode))
    }
}
