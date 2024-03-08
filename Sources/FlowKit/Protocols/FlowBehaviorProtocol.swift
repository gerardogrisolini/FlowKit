//
//  FlowBehaviorProtocol.swift
//  
//
//  Created by Gerardo Grisolini on 26/04/23.
//

/// FlowBehaviorProtocol is the protocol for the flow behavior
public protocol FlowBehaviorProtocol {
    var isEmpty: Bool { get }
    var localizables: [any LocalizableJoinProtocol] { get }
    var outs: [any OutJoinProtocol] { get }
    var events: [any EventJoinProtocol] { get }
}
