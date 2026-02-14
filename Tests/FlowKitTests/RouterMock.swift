//
//  RouterMock.swift
//  FlowKitTests
//
//  Created by Gerardo Grisolini on 06/03/24.
//

import Combine
import SwiftUI
import NavigationKit
@testable import FlowKit

final class RouterMock: RouterProtocol {
    let action = PassthroughSubject<RouterAction, Never>()
    var routes: [String] = []
    var items = RouterItems()
    var presentMode: PresentMode?
    var routerAction: RouterAction? = nil
#if canImport(UIKit) && !os(visionOS)
    var navigationController: UINavigationController? = nil
#endif

    var currentView: (any FlowViewProtocol)? = nil

    private func updateCurrentView() {
        guard let routeString = routes.last, let view = items.getValue(for: routeString) as? any FlowViewProtocol else {
            currentView = nil
            return
        }
        currentView = view
    }

    func setView() async {
        updateCurrentView()
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
        routerAction = .navigate(routeString)
        action.send(routerAction!)
        updateCurrentView()
    }

    func present(_ mode: PresentMode) {
        presentMode = mode
        if let routeString = mode.routeString {
            routes.append(routeString)
        }
        routerAction = .present(mode)
        action.send(routerAction!)
    }

    func pop() {
        let route = routes.removeLast()
        routerAction = .pop(route)
        action.send(routerAction!)
        updateCurrentView()
    }

    func popToFlow() {
        routes = []
        routerAction = .popToRoot
        action.send(routerAction!)
        updateCurrentView()
    }

    func popToRoot() {
        routes = []
        routerAction = .popToRoot
        action.send(routerAction!)
        updateCurrentView()
    }

    func dismiss() {
        if let mode = presentMode {
            if let routeString = mode.routeString {
                routes.removeAll(where: { $0 == routeString })
            }
            routerAction = .dismiss
            action.send(routerAction!)
        }
    }
}
