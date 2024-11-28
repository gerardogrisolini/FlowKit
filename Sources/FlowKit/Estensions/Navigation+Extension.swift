//
//  Navigation+Extension.swift
//  
//
//  Created by Gerardo Grisolini on 22/02/23.
//

public extension NavigationProtocol {

    /// Register a route with a view
    /// - Parameters:
    /// - route: the route
    /// - with: the closure of navigable view
    func register(route: some Routable, with: @escaping @Sendable (any InOutProtocol) -> (any Sendable)) async {
        let routeString = route.routeString
        items.setValue(for: routeString, value: with)
	}

    /// Register a route with param for a view
    /// - Parameters:
    /// - route: the route
    /// - with: the closure of navigable view
    func register<R: Routable, M: InOutProtocol>(route: JoinRoute<R, M>, with: @escaping @Sendable (M) -> (any Sendable)) async {
        let routeString = route.0.routeString
        items.setValue(for: routeString, value: { param in with(param as! M) })
    }

    /// Get a flow with a route
    /// - Parameters:
    /// - route: the route of flow
    /// - Returns: the flow
	func flow(route: some Routable) throws -> (any FlowProtocol) {
        let routeString = route.routeString
        guard items.setParam(for: routeString, param: route.associated.value),
              let flow = items.getValue(for: routeString) as? (any FlowProtocol) else {
            throw FlowError.routeNotFound
        }

        routes.append(routeString)

		return flow
	}
	
    /// Navigate to a view
    /// - Parameters:
    /// - view: the navigable view
	func navigate(view: any Sendable) async {
		let routeString = String(describing: view)
        await items.setValue(for: routeString, value: { _ in view })
		await navigate(routeString: routeString)
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
