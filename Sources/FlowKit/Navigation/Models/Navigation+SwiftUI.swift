//
//  NavigationSwiftUI.swift
//  FlowCommon
//
//  Created by Gerardo Grisolini on 11/10/22.
//

import SwiftUI
import Combine

public class NavigationSwiftUI: NavigationProtocol {
#if canImport(UIKit)
    public var navigationController: UINavigationController? = nil
#endif
    public var action = PassthroughSubject<NavigationAction, Never>()
	public var routes: [String] = []
    public var items = NavigationItems()

	required public init() { }

    public func navigate(routeString: String) {
        routes.append(routeString)
        action.send(.navigate(routeString))
    }
    
    public func present(routeString: String) {
        routes.append(routeString)
        action.send(.present(routeString))
    }
    
	public func navigate(route: some Routable) throws {
		let routeString = "\(route)"
        guard items.contains(routeString) else {
			throw FlowError.routeNotFound
		}
		navigate(routeString: routeString)
	}

	public func present(route: some Routable) throws {
		let routeString = "\(route)"
		guard items.contains(routeString) else {
			throw FlowError.routeNotFound
		}
		present(routeString: routeString)
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
		action.send(.dismiss)

        if let route = routes.popLast() {
            removeRoute(route)
        }
	}
}
