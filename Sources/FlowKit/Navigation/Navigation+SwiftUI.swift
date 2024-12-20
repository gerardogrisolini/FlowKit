//
//  NavigationSwiftUI.swift
//
//
//  Created by Gerardo Grisolini on 11/10/22.
//

import SwiftUI
import Combine

public final class NavigationSwiftUI: NavigationProtocol {

    public let action = PassthroughSubject<NavigationAction, Never>()
	public var routes: [String] = []
    public var items = NavigationItems()
    public var presentMode: PresentMode? = nil


    public func navigate(routeString: String) {
        routes.append(routeString)
        action.send(.navigate(routeString))
    }

	public func navigate(route: some Routable) throws {
        let routeString = route.routeString
        guard items.setParam(for: routeString, param: route.associated.value) else {
			throw FlowError.routeNotFound
		}
		navigate(routeString: routeString)
	}

	private func removeRoute(_ route: String) {
        let view = items.getValue(for: route)

        if let view = view as? any FlowViewProtocol {
            view.events.finish()
        }

        guard view is any FlowProtocol else {
            items.remove(route)
            return
        }
    }

	public func pop() {
		if let route = routes.popLast() {
            removeRoute(route)
			action.send(.pop(route))
		}
	}

    public func popToFlow() {
        while let route = routes.popLast() {
            removeRoute(route)

            if items.getValue(for: route) is any FlowProtocol {
                break
            }

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
