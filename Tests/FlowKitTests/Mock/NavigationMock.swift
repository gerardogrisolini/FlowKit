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
        navigate(routeString: "\(route)")
    }

    func navigate(routeString: String) {
        routes.append(routeString)
        navigationAction = .navigate(routeString)
    }

    func present(route: some Routable) throws {
        present(.sheet(EmptyView()))
    }

    func present(_ mode: PresentMode) {
        presentMode = mode
        if let routeString = mode.routeString {
            routes.append(routeString)
        }
        navigationAction = .present(mode)
    }

    func pop() {
        routes.removeLast()
        navigationAction = .pop("")
    }

    func popToFlow() {
        routes = []
        navigationAction = .popToRoot
    }

    func popToRoot() {
        routes = []
        navigationAction = .popToRoot
    }

    func dismiss() {
        if let mode = presentMode {
            if let routeString = mode.routeString {
                routes.removeAll(where: { $0 == routeString })
            }
            navigationAction = .dismiss
        }
    }
}
