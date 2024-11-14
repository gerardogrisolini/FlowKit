//
//  FlowKit.swift
//
//  Framework for building modular applications with composable flows.
//

@_exported import Resolver
@_exported import FlowCases
@_exported import FlowView
@_exported import Flow

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
    public static func initialize(navigationType: NavigationType = .swiftUI, withFlowRouting: Bool = true) {
       switch navigationType {
        case .swiftUI:
           registerNavigationSwiftUI(withFlowRouting: withFlowRouting)
#if canImport(UIKit)
       case .uiKit(navigationController: let navigationController):
           registerNavigationUIKit(navigationController: navigationController, withFlowRouting: withFlowRouting)
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
    @discardableResult
    private static func register(navigation: NavigationProtocol, withFlowRouting: Bool) -> any NavigationProtocol {
        Resolver
            .register { navigation as NavigationProtocol }
            .scope(.application)

        guard withFlowRouting else { return navigation }

        Task.detached {
            print("Registering flows...")
            let classes = Self.classes(conformTo: FlowRouteProtocol.self)
            for item in classes {
                guard let flow = item as? (any FlowProtocol.Type) else { continue }
                print("\(flow.route)")
                await navigation.register(route: flow.route) { flow.init() }
            }
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

    /// Register the services
    /// - Parameters:
    /// - scope: scope of the service
    /// - factory: factory function
    public static func register<Service>(_ type: Service.Type = Service.self,
                           scope: ResolverScope,
                           factory: @escaping ResolverFactory<Service>) {
        Resolver.register { factory() }.scope(scope)
    }
}
