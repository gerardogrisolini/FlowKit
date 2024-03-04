//
//  Navigation+Extension.swift
//  
//
//  Created by Gerardo Grisolini on 22/02/23.
//

public extension NavigationProtocol {
	func register(route: some Routable, with: @escaping () -> (any Navigable)) {
        let routeString = "\(route)"
		items[routeString] = with
	}
	
	func flow(route: some Routable) throws -> (any FlowProtocol) {
		let routeString = "\(route)"
		guard let flow = items[routeString]?() as? any FlowProtocol else {
			throw FlowError.flowNotFound
		}

        routes.append(routeString)

		return flow
	}
	
	func navigate(view: some Navigable) {
		let routeString = String(describing: type(of: view))
		if !items.contains(routeString) {
			items[routeString] = { view }
		}
		navigate(routeString: routeString)
	}
	
	func present(view: some Presentable) {
		let routeString = String(describing: type(of: view))
		if !items.contains(routeString) {
			items[routeString] = { view }
		}
		present(routeString: routeString)
	}
}
