//
//  NavigationMock.swift
//  
//
//  Created by Gerardo Grisolini on 06/03/24.
//

import Combine
import SwiftUI
@testable import FlowKit

@MainActor
final class NavigationMock: NavigationProtocol {
    let action = PassthroughSubject<NavigationAction, Never>()
    var routes: [String] = []
    var items = NavigationItems()
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
        Task { @MainActor in
            routes.append(routeString)
            navigationAction = .navigate(routeString)
        }
    }

    func present(route: some Routable) throws {
        present(.sheet(EmptyView()))
    }

    func present(_ mode: PresentMode) {
        let routeString = String(describing: type(of: mode))
        Task { @MainActor in
            routes.append(routeString)
            navigationAction = .present(mode)
        }
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
