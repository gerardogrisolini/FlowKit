//
//  Navigation+Extension.swift
//  
//
//  Created by Gerardo Grisolini on 22/02/23.
//

import NavigationKit

extension NavigationProtocol {

    /// Get a flow with a route
    /// - Parameters:
    /// - route: the route of flow
    /// - Returns: the flow
    public func flow(route: some Routable) throws -> (any FlowProtocol) {
        let routeString = route.routeString
        guard items.setParam(for: routeString, param: route.associated.value),
              let flow = items.getValue(for: routeString) as? (any FlowProtocol) else {
            throw NavigationError.routeNotFound
        }

        routes.append(routeString)

        return flow
    }
}
