//
//  FlowKit.swift
//
//  Framework for building modular applications with composable flows.
//

@_exported import NavigationKit
@_exported import FlowView
@_exported import Flow

import Foundation
import SwiftUI

public struct FlowKit {

    /// Registering routing of flows
    @MainActor
    private static func inizializeFlowRouting(_ navigation: any NavigationProtocol) {
        print("Registering flows...")
        let classes = Self.classes(conformTo: FlowRouteProtocol.self)
        for item in classes {
            guard let flow = item as? (any FlowProtocol.Type) else { continue }
            print(flow.route.routeString)
            navigation.register(route: flow.route, with: flow.init)
        }
    }
    
    /// Inizialize the navigation from type
    /// - Parameters:
    /// - navigationType: the navigation type to use
    /// - Returns: the navigation
    @MainActor
    @discardableResult
    public static func initialize(navigationType: NavigationType = .swiftUI, withFlowRouting: Bool = true) -> any NavigationProtocol {
        let navigation: NavigationProtocol
        switch navigationType {
        case .swiftUI:
            navigation = FlowNavigationSwiftUI()
            initialize(navigation: navigation)
#if canImport(UIKit)
        case .uiKit(navigationController: let navigationController):
            let nav = FlowNavigationUIKit()
            nav.navigationController = navigationController
            navigation = nav
#endif
        }
        initialize(navigation: navigation)

        guard withFlowRouting else { return navigation }

        inizializeFlowRouting(navigation)

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
}

/// FlowError is the error type for the flow
public enum FlowError: Error {
    case generic, flowNotFound, eventNotFound, invalidModel(String), partialMapping(String)
}
