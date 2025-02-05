//
//  Navigation+Extension.swift
//  
//
//  Created by Gerardo Grisolini on 22/02/23.
//

public typealias JoinRoute<R: Routable, M: InOutProtocol> = (R, M)

public extension NavigationProtocol {

    /// Register a route with param for a view
    /// - Parameters:
    /// - route: the route
    /// - with: the closure of navigable view
    func register<R: Routable, M: InOutProtocol>(route: JoinRoute<R, M>, with: @escaping @MainActor @Sendable (M) -> (any Sendable)) {
        let routeString = route.0.routeString
        items.setValue(for: routeString, value: { param in with(param as! M) })
    }

    /// Register a route with a view
    /// - Parameters:
    /// - route: the route
    /// - with: the closure of navigable view
    func register(route: some Routable, with: @escaping @MainActor @Sendable () -> (any Sendable)) {
        let routeString = route.routeString
        items.setValue(for: routeString, value: { _ in with() })
	}

    /// Navigate to a view
    /// - Parameters:
    /// - view: the navigable view
	func navigate(view: any Sendable) {
		let routeString = String(describing: type(of: view))
        items.setValue(for: routeString, value: { _ in view })
		navigate(routeString: routeString)
	}
	
    /// Present a view
    /// - Parameters:
    /// - mode: Presentation mode
    func present(_ mode: PresentMode) {
        presentMode = mode

        if let route = mode.routeString {
            routes.append(route)
        }
        action.send(.present(mode))
    }
}
