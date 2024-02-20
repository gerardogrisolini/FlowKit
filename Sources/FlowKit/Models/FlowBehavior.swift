//
//  FlowBehavior.swift
//  
//
//  Created by Gerardo Grisolini on 26/04/23.
//

public typealias Out = (any InOutProtocol) async throws -> Results
public typealias Event = (any FlowEventProtocol) async throws -> any InOutProtocol

public enum Results {
    case model(any InOutProtocol)
    case node(any CoordinatorNodeProtocol, any InOutProtocol)
//    case route(any Routable, any InOutProtocol)
}

public struct FlowBehavior: FlowBehaviorProtocol {
    public var localizables: [any LocalizableJoinProtocol] = []
    public var outs: [any OutJoinProtocol] = []
    public var events: [any EventJoinProtocol] = []
    public var isEmpty: Bool { localizables.isEmpty && outs.isEmpty && events.isEmpty }

    public init() { }

    public init(@BehaviorsBuilder _ content: () -> [Behaviors]) {
        let items = content()
        for item in items {
            switch item {
            case .localizable(let localizables):
                self.localizables = localizables
            case .out(let outs):
                self.outs = outs
            case .event(let events):
                self.events = events
            }
        }
    }
}
