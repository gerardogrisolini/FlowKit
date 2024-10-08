//
//  CoordinatorProtocol.swift
//  
//
//  Created by Gerardo Grisolini on 02/02/23.
//

/// CoordinatorJoinProtocol is the protocol for the coordinator join
public protocol CoordinatorJoinProtocol {
    associatedtype Event: FlowOutProtocol
    associatedtype Node: Nodable

    var event: Event { get }
    var node: Node { get }
}

/// CoordinatorNodeProtocol is the protocol for the coordinator node
public protocol CoordinatorNodeProtocol: Nodable {
	associatedtype View: FlowViewProtocol

	var view: View.Type { get }
    var model: View.In.Type { get }
	var joins: [any CoordinatorJoinProtocol] { get }
    var eventsCount: Int { get }
}

/// CoordinatorProtocol is the protocol for the coordinator
public protocol CoordinatorProtocol {
    associatedtype Flow: FlowProtocol
    var flow: Flow { get }
    var parent: (any FlowViewProtocol)? { get }
    func start(model: Flow.CoordinatorNode.View.In, navigate: Bool) async throws
}

/// Presentable is the protocol for the presentable view
public protocol Presentable: Navigable {
    /// Dismiss the view
    var dismiss: () -> () { get }
}

extension Presentable {
    public var dismiss: () -> () { Resolver.resolve(NavigationProtocol.self).dismiss }
}

extension CoordinatorNodeProtocol {
    /// Function to validate the model
    /// - Parameters:
    /// - model: the model to validate
    func validate(className fromId: String) throws {
        let toId = String(describing: view.In).className
        guard fromId == toId else {
            let error = "\(String(describing: view)): \(fromId) -> \(toId)"
            throw FlowError.invalidModel(error)
        }
    }
}
