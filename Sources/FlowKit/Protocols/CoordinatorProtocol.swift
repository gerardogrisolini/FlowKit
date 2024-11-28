//
//  CoordinatorProtocol.swift
//  
//
//  Created by Gerardo Grisolini on 02/02/23.
//

/// CoordinatorJoinProtocol is the protocol for the coordinator join
public protocol CoordinatorJoinProtocol: Sendable {
    associatedtype Event: FlowOutProtocol
    associatedtype Node: Nodable

    var event: Event { get }
    var node: Node { get }
}

/// CoordinatorNodeProtocol is the protocol for the coordinator node
public protocol CoordinatorNodeProtocol: Nodable {
	associatedtype View: FlowViewProtocol

	var view: View.Type { get }
	var joins: [any CoordinatorJoinProtocol] { get }
    var eventsCount: Int { get }
}

/// CoordinatorProtocol is the protocol for the coordinator
public protocol CoordinatorProtocol {
    associatedtype Flow: FlowProtocol
    var flow: Flow { get }
    var parent: (any FlowViewProtocol)? { get }
    func start(navigate: Bool) async throws
}

extension CoordinatorNodeProtocol {
    /// Function to validate the model
    /// - Parameters:
    /// - className: the class name
    func validate(className fromId: String) throws {
        let toId = String(describing: view.In).className
        guard fromId == toId else {
            let error = "\(String(describing: view)): \(fromId) -> \(toId)"
            throw FlowError.invalidModel(error)
        }
    }
}
