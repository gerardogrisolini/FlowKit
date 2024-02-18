//
//  NavigationProtocol.swift
// 
//
//  Created by Gerardo Grisolini on 11/10/22.
//

#if canImport(UIKit)
import UIKit
#endif
import Combine

public protocol Navigable { }
public protocol Nodable { }
public protocol Routable: Nodable { }

public protocol NavigationProtocol: AnyObject {
#if canImport(UIKit)
    var navigationController: UINavigationController? { get set }
#endif
    var action: PassthroughSubject<NavigationAction, Never> { get }
	var routes: [String] { get set }
	var items: [String: () -> (any Navigable)] { get set }
    var onDismiss: (() -> ())? { get set }
	
	init()
	func register(route: some Routable, with: @escaping () -> (any Navigable))
	func flow(route: some Routable) throws -> (any FlowProtocol)

    func navigate(routeString: String)
    func present(routeString: String)

    func navigate(view: some Navigable)
	func present(view: some Presentable)

	func navigate(route: some Routable) throws
	func present(route: some Routable) throws

	func pop()
	func popToRoot()
	func dismiss()
}
