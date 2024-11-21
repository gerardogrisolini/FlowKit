//
//  Navigation+Extension.swift
//  
//
//  Created by Gerardo Grisolini on 22/02/23.
//

@MainActor
public extension NavigationProtocol {

    /// Register a route with a view
    /// - Parameters:
    /// - route: the route
    /// - with: the closure of navigable view
    func register(route: some Routable, with: @escaping @Sendable () -> (any Sendable)) {
        let routeString = "\(route)"
        items[routeString] = with
	}
	
    /// Get a flow with a route
    /// - Parameters:
    /// - route: the route of flow
    /// - Returns: the flow
	func flow(route: some Routable) throws -> (any FlowProtocol) {
		let routeString = "\(route)"
		guard let flow = items[routeString]?() as? any FlowProtocol else {
			throw FlowError.flowNotFound
		}

        routes.append(routeString)

		return flow
	}
	
    /// Navigate to a view
    /// - Parameters:
    /// - view: the navigable view
	func navigate(view: any Sendable) {
		let routeString = String(describing: type(of: view))
		if !items.contains(routeString) {
			items[routeString] = { view }
		}
		navigate(routeString: routeString)
	}
	
    /// Present a view
    /// - Parameters:
    /// - mode: Presentation mode
    func present(_ mode: PresentMode) {
        if let route = mode.routeString {
            routes.append(route)
        }
        action.send(.present(mode))
    }
}
