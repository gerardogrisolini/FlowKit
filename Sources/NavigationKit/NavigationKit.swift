//
//  NavigationKit.swift
//  NavigationKit
//
//  Framework for navigating on modular application.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
@_exported import FlowCases

public enum NavigationType {
#if canImport(UIKit)
    case uiKit(navigationController: UINavigationController)
#endif
    case swiftUI
}

public struct NavigationKit {

    /// Inizialize the navigation from type
    /// - Parameters:
    /// - navigationType: the navigation type to use
    /// - Returns: the router
    @MainActor
    @discardableResult
    public static func initialize(navigationType: NavigationType = .swiftUI) -> any RouterProtocol {
        let router: RouterProtocol
        switch navigationType {
        case .swiftUI:
            router = RouterSwiftUI()
            initialize(router: router)
#if canImport(UIKit)
        case .uiKit(navigationController: let navigationController):
            let r = RouterUIKit()
            r.navigationController = navigationController
            router = r
#endif
        }
        initialize(router: router)
        return router
    }

    /// Inizialize the navigation
    /// - Parameters:
    /// - router: the router to use
    @MainActor
    static func initialize(router: RouterProtocol) {
        InjectedValues[\.router] = router
    }
}

/// Dependency injection for navigation
private struct RouterProvider: @preconcurrency InjectionProvider {
    @MainActor static var currentValue: RouterProtocol = RouterSwiftUI()
}

public extension InjectedValues {
    @MainActor
    var router: RouterProtocol {
        get { Self[RouterProvider.self] }
        set { Self[RouterProvider.self] = newValue }
    }
}

/// NavigationError is the error type for the navigation
public enum NavigationError: Error {
    case routeNotFound
}
