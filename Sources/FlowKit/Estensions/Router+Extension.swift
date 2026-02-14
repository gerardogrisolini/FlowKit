//
//  Router+Extension.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 22/02/23.
//

import NavigationKit

extension RouterProtocol {

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

    /// Pops all view controllers until it reaches the starting point of a navigation flow.
    /// This iterates through the stack, removing routes and sending `.pop` actions.
    public func popToFlow() {
        guard let view = self as? FlowRouterSwiftUI else {
#if canImport(UIKit) && !os(visionOS)
            guard let view = self as? FlowRouterUIKit else { return }
            view.popToFlow()
#endif
            return
        }
        view.popToFlow()
    }
}
