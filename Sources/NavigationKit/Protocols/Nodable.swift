//
//  Nodable.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

/// Nodable is the protocol that must implement to be nodable
public protocol Nodable: Identifiable, Sendable {

    associatedtype Model: InOutProtocol
    var model: Model.Type { get }

    func udpate(associatedValue: some InOutProtocol) -> Self
}
