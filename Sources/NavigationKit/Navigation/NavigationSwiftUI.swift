//
//  NavigationSwiftUI.swift
//
//
//  Created by Gerardo Grisolini on 11/10/22.
//

import SwiftUI
import Combine

open class NavigationSwiftUI: NavigationProtocol {

    public let action = PassthroughSubject<NavigationAction, Never>()
	public var routes: [String] = []
    public var items = NavigationItems()
    public var presentMode: PresentMode? = nil

    public init() { }

    public func navigate(routeString: String) {
        routes.append(routeString)
        action.send(.navigate(routeString))
    }

	public func navigate(route: some Routable) throws {
        let routeString = route.routeString
        guard items.setParam(for: routeString, param: route.associated.value) else {
			throw NavigationError.routeNotFound
		}
		navigate(routeString: routeString)
	}

	open func removeRoute(_ route: String) {
        items.remove(route)
    }

	public func pop() {
		if let route = routes.popLast() {
            removeRoute(route)
			action.send(.pop(route))
		}
	}

    open func popToFlow() {
        while let route = routes.popLast() {
            removeRoute(route)
            action.send(.pop(route))
		}
	}

    public func popToRoot() {
        while let route = routes.popLast() {
            removeRoute(route)
        }
        action.send(.popToRoot)
    }
    
    public func dismiss() {
        if let _ = presentMode {
            action.send(.dismiss)

            if let routeString = presentMode?.routeString {
                routes.removeAll(where: { $0 == routeString })
            }
            presentMode = nil
        }
	}
}
