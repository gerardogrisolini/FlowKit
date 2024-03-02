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
	public var items: [String : () -> (any Navigable)] = [:]
    public var onDismiss: (() -> ())? = nil

	required public init() { }

    public func navigate(routeString: String) {
        routes.append(routeString)
        action.send(.navigate(routeString))
    }
    
    public func present(routeString: String) {
        action.send(.present(routeString))
    }
    
	public func navigate(route: some Routable) throws {
		let routeString = "\(route)"
		guard items.keys.contains(routeString) else {
			throw FlowError.routeNotFound
		}
		navigate(routeString: routeString)
	}

	public func present(route: some Routable) throws {
		let routeString = "\(route)"
		guard items.keys.contains(routeString) else {
			throw FlowError.routeNotFound
		}
		present(routeString: routeString)
	}

	private func removeRoute(_ route: String) {
        guard let view = items[route]?() as? any FlowViewProtocol else {
            return
        }
        view.events.finish()
        items.removeValue(forKey: route)
	}
	
	public func pop() {
		if let route = routes.popLast() {
			removeRoute(route)
			action.send(.pop(route))
		}
	}
		
    public func popToView(routeString: String) {
        while let route = routes.popLast() {
			removeRoute(route)
            action.send(.pop(route))
            guard routeString != route else { break }
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
        onDismiss?()
	}
}
