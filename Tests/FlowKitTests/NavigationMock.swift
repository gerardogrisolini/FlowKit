//
//  NavigationMock.swift
//  
//
//  Created by Gerardo Grisolini on 06/03/24.
//

import Combine
import SwiftUI
import NavigationKit
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

    var currentView: (any FlowViewProtocol)? = nil

    func setView() async {
        guard let routeString = routes.last, let view = items.getValue(for: routeString) as? any FlowViewProtocol else {
            currentView = nil
            return
        }
        currentView = view
    }

    func navigate(route: some Routable) throws {
        let routeString = route.routeString
        guard items.setParam(for: routeString, param: route.associated.value) else {
            throw NavigationError.routeNotFound
        }
        navigate(routeString: routeString)
    }

    func navigate(routeString: String) {
        routes.append(routeString)
        navigationAction = .navigate(routeString)
        action.send(navigationAction!)
        Task { @MainActor in
            await setView()
        }
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
