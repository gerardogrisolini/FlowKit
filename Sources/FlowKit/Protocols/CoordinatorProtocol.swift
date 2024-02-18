//
//  CoordinatorProtocol.swift
//  
//
//  Created by Gerardo Grisolini on 02/02/23.
//

import Resolver

public protocol CoordinatorJoinProtocol {
    associatedtype Event: FlowOutProtocol

    var event: Event { get }
    var node: any Nodable { get }
}

public protocol CoordinatorNodeProtocol: Nodable {
	associatedtype View: FlowViewProtocol

	var view: View.Type { get }
    var `in`: View.In.Type { get }
	var joins: [any CoordinatorJoinProtocol] { get }
    var eventsCount: Int { get }
}

public protocol CoordinatorProtocol {
    associatedtype Flow: FlowProtocol
    var flow: Flow { get }
    func start(model: Flow.CoordinatorNode.View.In) async throws -> Flow.Model
}

public protocol Presentable: Navigable {
    var dismiss: () -> () { get }
}

extension Presentable {
    public var dismiss: () -> () { Resolver.resolve(NavigationProtocol.self).dismiss }
}

extension CoordinatorNodeProtocol {
    public func validate(model: any InOutProtocol) throws {
        let fromId = String(describing: model).id
        let toId = String(describing: self.view.In).id
        guard fromId == toId else {
            let error = "\(String(describing: self.view)): \(fromId) -> \(toId)"
            throw FlowError.invalidModel(error)
        }
    }
}
