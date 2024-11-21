//
//  NavigationMock.swift
//  
//
//  Created by Gerardo Grisolini on 06/03/24.
//

import Combine
import SwiftUI
@testable import FlowKit

final class NavigationMock: NavigationProtocol {
    let action = PassthroughSubject<NavigationAction, Never>()
    var routes: [String] = []
    var items = NavigationItems()
    var presentMode: PresentMode?
    var navigationAction: NavigationAction? = nil
#if canImport(UIKit)
    var navigationController: UINavigationController? = nil
#endif

    var currentView: (any FlowViewProtocol)? {
        guard let route = routes.last, let view = items[route]?() as? any FlowViewProtocol else {
            return nil
        }
        return view
    }

    func navigate(route: some Routable) throws {
        navigationAction = .navigate("\(route)")
        action.send(navigationAction!)
    }

    func navigate(routeString: String) {
        routes.append(routeString)
        navigationAction = .navigate(routeString)
        action.send(navigationAction!)
    }

    func present(_ mode: PresentMode) {
        presentMode = mode
        if let routeString = mode.routeString {
            routes.append(routeString)
        }
        navigationAction = .present(mode)
        action.send(navigationAction!)
    }

    func pop() {
        let route = routes.removeLast()
        navigationAction = .pop(route)
        action.send(navigationAction!)
    }

    func popToFlow() {
        routes = []
        navigationAction = .popToRoot
        action.send(navigationAction!)
    }

    func popToRoot() {
        routes = []
        navigationAction = .popToRoot
        action.send(navigationAction!)
    }

    func dismiss() {
        if let mode = presentMode {
            if let routeString = mode.routeString {
                routes.removeAll(where: { $0 == routeString })
            }
            navigationAction = .dismiss
            action.send(navigationAction!)
        }
    }
}
