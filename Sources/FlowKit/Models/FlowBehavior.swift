//
//  FlowBehavior.swift
//  
//
//  Created by Gerardo Grisolini on 26/04/23.
//

import Resolver

public final class FlowBehavior {
    public var commands = Dictionary<AnyHashable, Command>()
    public var keys = Dictionary<AnyHashable, String>()

    public init() { }

    public func set(_ command: @escaping Command, for event: AnyHashable) {
        commands[event] = command
    }

    public func set(_ key: some Localizable, for current: some Localizable) {
        keys[current] = key.localized
    }
}

public enum Results {
    case model(any InOutProtocol)
    case node(any CoordinatorNodeProtocol, any InOutProtocol)
//    case route(any Routable, any InOutProtocol)
}

public typealias Command = (any InOutProtocol) async throws -> (Results)
