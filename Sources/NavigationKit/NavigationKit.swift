//
//  NavigationKit.swift
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
    /// - Returns: the navigation
    @MainActor
    @discardableResult
    public static func initialize(navigationType: NavigationType = .swiftUI) -> any NavigationProtocol {
        let navigation: NavigationProtocol
        switch navigationType {
        case .swiftUI:
            navigation = NavigationSwiftUI()
            initialize(navigation: navigation)
#if canImport(UIKit)
        case .uiKit(navigationController: let navigationController):
            let nav = NavigationUIKit()
            nav.navigationController = navigationController
            navigation = nav
#endif
        }
        initialize(navigation: navigation)
        return navigation
    }

    /// Inizialize the navigation
    /// - Parameters:
    /// - navigation: the navigation to use
    /// - Returns: the navigation
    @MainActor
    static func initialize(navigation: NavigationProtocol) {
        InjectedValues[\.navigation] = navigation
    }
}

/// Dependency injection for navigation
private struct NavigationProvider: @preconcurrency InjectionProvider {
    @MainActor static var currentValue: NavigationProtocol = NavigationSwiftUI()
}

public extension InjectedValues {
    var navigation: NavigationProtocol {
        get { Self[NavigationProvider.self] }
        set { Self[NavigationProvider.self] = newValue }
    }
}

/// NavigationError is the error type for the navigation
public enum NavigationError: Error {
    case routeNotFound
}
