//
//  NavigationSwiftUI.swift
//
//
//  Created by Gerardo Grisolini on 11/10/22.
//

import SwiftUI
import Combine

public final class NavigationSwiftUI: NavigationProtocol {
    public var action = PassthroughSubject<NavigationAction, Never>()
	public var routes: [String] = []
    public var items = NavigationItems()
    public var presentMode: PresentMode? = nil


    public func navigate(routeString: String) {
        routes.append(routeString)
        action.send(.navigate(routeString))
    }

	public func navigate(route: some Routable) throws {
		let routeString = "\(route)"
        guard items.contains(routeString) else {
			throw FlowError.routeNotFound
		}
		navigate(routeString: routeString)
	}

	private func removeRoute(_ route: String) {
        let view = items[route]?()

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

            if items[route]?() is any FlowProtocol {
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
        if let mode = presentMode {
            action.send(.dismiss)

            if let routeString = mode.routeString {
                routes.removeAll(where: { $0 == routeString })
            }
            presentMode = nil
        }
	}
}
