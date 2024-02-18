//
//  Inject.swift
//  
//
//  Created by Gerardo Grisolini on 27/08/23.
//

import SwiftUI
import Resolver

// MARK: - Routing flow registration

public extension App {

    static private func allClasses() -> [AnyClass] {
        let numberOfClasses = Int(objc_getClassList(nil, 0))
        if numberOfClasses > 0 {
            let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
            let autoreleasingClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
            let count = objc_getClassList(autoreleasingClasses, Int32(numberOfClasses))
            //assert(numberOfClasses == count)
            defer { classesPtr.deallocate() }
            let classes = (0 ..< numberOfClasses).map { classesPtr[$0] }
            return classes
        }
        return []
    }

    private static func classes(conformTo: Protocol) -> [AnyClass] {
        allClasses().filter { class_conformsToProtocol($0, conformTo) }
    }

    public func register(navigation: NavigationProtocol) {
        Resolver.register { navigation as NavigationProtocol }.scope(.application)

        let classes = Self.classes(conformTo: FlowRouteProtocol.self)
        for item in classes {
            guard let flow = item as? (any FlowProtocol.Type) else { continue }
            navigation.register(route: flow.route) { flow.init() }
        }
    }

    public func register<Service>(_ type: Service.Type = Service.self,
                                  scope: ResolverScope,
                                  factory: @escaping ResolverFactory<Service>) {
        Resolver.register { factory() }.scope(scope)
    }
}
