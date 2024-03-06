//
//  NavigationMock.swift
//  
//
//  Created by Gerardo Grisolini on 06/03/24.
//

import Combine
import SwiftUI
@testable import FlowKit

class NavigationMock: NavigationProtocol {
    var navigationController: UINavigationController?
    let action = PassthroughSubject<NavigationAction, Never>()
    var routes: [String] = []
    var items = NavigationItems()

    var navigationAction: NavigationAction? = nil
    var currentView: (any FlowViewProtocol)? {
        guard let route = routes.last, let view = items[route]?() as? any FlowViewProtocol else {
            return nil
        }
        return view
    }

    required init() { }

    func navigate(route: some Routable) throws {
        navigate(routeString: "\(route)")
    }

    func navigate(routeString: String) {
        routes.append(routeString)
        navigationAction = .navigate(routeString)
    }

    func present(route: some Routable) throws {
        present(routeString: "\(route)")
    }

    func present(routeString: String) {
        routes.append(routeString)
        navigationAction = .present(routeString)
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
        routes.removeLast()
        navigationAction = .dismiss
    }
}
