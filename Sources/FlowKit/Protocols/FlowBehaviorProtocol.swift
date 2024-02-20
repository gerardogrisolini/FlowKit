//
//  FlowBehaviorProtocol.swift
//  
//
//  Created by Gerardo Grisolini on 26/04/23.
//

import Foundation

public protocol FlowBehaviorProtocol {
    var isEmpty: Bool { get }
    var localizables: [any LocalizableJoinProtocol] { get }
    var outs: [any OutJoinProtocol] { get }
    var events: [any EventJoinProtocol] { get }
}
