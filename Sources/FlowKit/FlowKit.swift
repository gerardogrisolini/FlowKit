//
//  FlowKit.swift
//
//  Framework for building modular applications with composable flows.
//

@_exported import FlowCases
@_exported import FlowView
@_exported import Flow

import Foundation
import SwiftUI

public struct FlowKit {
    public enum NavigationType {
#if canImport(UIKit)
        case swiftUI, uiKit(navigationController: UINavigationController)
#else
        case swiftUI
#endif
    }

    @MainActor
    @discardableResult
    public static func initialize(navigationType: NavigationType = .swiftUI, withFlowRouting: Bool = true) -> any NavigationProtocol {
        switch navigationType {
        case .swiftUI:
            return registerNavigationSwiftUI(withFlowRouting: withFlowRouting)
#if canImport(UIKit)
        case .uiKit(navigationController: let navigationController):
            return registerNavigationUIKit(navigationController: navigationController, withFlowRouting: withFlowRouting)
#endif
        }
    }

    /// Get all classes of the app
    private static func allClasses() -> [AnyClass] {
        let numberOfClasses = Int(objc_getClassList(nil, 0))
        if numberOfClasses > 0 {
            let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
            let autoreleasingClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
            let count = objc_getClassList(autoreleasingClasses, Int32(numberOfClasses))
            guard numberOfClasses == count else { return [] }
            defer { classesPtr.deallocate() }
            let classes = (0 ..< numberOfClasses).map { classesPtr[$0] }
            return classes
        }
        return []
    }

    /// Get all classes conforming to a protocol
    /// - Parameters:
    /// - conformTo: the protocol to conform to
    /// - Returns: the classes conforming to the protocol
    private static func classes(conformTo: Protocol) -> [AnyClass] {
        allClasses().filter { class_conformsToProtocol($0, conformTo) }
    }

    /// Register the navigation and the routing of flows
    /// - Parameters:
    /// - navigation: the navigation to use
    /// - withFlowRouting: if true, it also registers the routing of the flows
    /// - Returns: the navigation
    @MainActor
    @discardableResult
    private static func register(navigation: NavigationProtocol, withFlowRouting: Bool) -> any NavigationProtocol {
        InjectedValues[\.navigation] = navigation

        guard withFlowRouting else { return navigation }

        print("Registering flows...")
        let classes = Self.classes(conformTo: FlowRouteProtocol.self)
        for item in classes {
            guard let flow = item as? (any FlowProtocol.Type) else { continue }
            print(flow.route.routeString)
            navigation.register(route: flow.route, with: flow.init)
        }

        return navigation
    }

    /// Register the SwiftUI navigation and the routing of flows
    /// - Parameters:
    ///  - withFlowRouting: if true, it also registers the routing of the flows
    @MainActor
    @discardableResult
    static func registerNavigationSwiftUI(withFlowRouting: Bool = true) -> any NavigationProtocol {
        let navigation = NavigationSwiftUI()
        return register(navigation: navigation, withFlowRouting: withFlowRouting)
    }

#if canImport(UIKit)
    /// Register the UIKit navigation and the routing of flows
    /// - Parameters:
    ///  - navigationController: the navigation controller to use
    ///  - withFlowRouting: if true, it also registers the routing of the flows
    @MainActor
    @discardableResult
    static func registerNavigationUIKit(navigationController: UINavigationController, withFlowRouting: Bool = true) -> any NavigationProtocol {
        let navigation = NavigationUIKit()
        navigation.navigationController = navigationController
        return register(navigation: navigation, withFlowRouting: withFlowRouting)
    }
#endif
}

// MARK: - Dependency injection

public protocol InjectionKey {

    /// The associated type representing the type of the dependency injection key's value.
    associatedtype Value

    /// The default value for the dependency injection key.
    static var currentValue: Self.Value { get set }
}

/// Provides access to injected dependencies.
public struct InjectedValues {

    /// This is only used as an accessor to the computed properties within extensions of `InjectedValues`.
    nonisolated(unsafe) private static var current = InjectedValues()

    /// A static subscript for updating the `currentValue` of `InjectionKey` instances.
    public static subscript<K>(key: K.Type) -> K.Value where K : InjectionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    /// A static subscript accessor for updating and references dependencies directly.
    public static subscript<T>(_ keyPath: WritableKeyPath<InjectedValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}

/// This allows us to reference dependencies using the key path accessor as shown
@propertyWrapper
@MainActor public struct Injected<T> {
    private let keyPath: WritableKeyPath<InjectedValues, T>
    public var wrappedValue: T {
        get { InjectedValues[keyPath] }
        set { InjectedValues[keyPath] = newValue }
    }

    public init(_ keyPath: WritableKeyPath<InjectedValues, T>) {
        self.keyPath = keyPath
    }
}
