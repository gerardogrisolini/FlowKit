//
//  NavigationUIKit.swift
//  FlowCommon
//
//  Created by Gerardo Grisolini on 11/10/22.
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import Combine

@available(iOS 14.0, *)
public final class NavigationUIKit: NSObject, NavigationProtocol, UINavigationControllerDelegate {
    public var navigationController: UINavigationController? {
        didSet {
            navigationController?.delegate = self
            navigationController?.navigationBar.prefersLargeTitles = true
//            navigationController?.navigationBar.isHidden = true
//            navigationController?.navigationItem.hidesBackButton = true

//            routes = navigationController!
//                .viewControllers
//                .map { $0 as! UIHostingController<AnyView> }
//                .map { $0.rootView }
//                .map { String(describing: type(of: $0)) }
        }
    }
	public var action = PassthroughSubject<NavigationAction, Never>()
    public var routes: [String] = []
	public var items: [String : () -> (any Navigable)] = [:]
    public var onDismiss: (() -> ())? = nil

    public func navigate(routeString: String) {
         try? push(route: routeString)
    }
    
    public func present(routeString: String) {
        try? present(route: routeString)
    }
    
    public func navigate(route: some Routable) throws {
        try push(route: "\(route)")
    }
    
    public func present(route: some Routable) throws {
        try present(route: "\(route)")
    }
    
	public func push(route: String) throws {
        routes.append(route)

        guard let view = items[route]?() as? any View else {
            guard let vc = items[route]?() as? UIViewController else {
                throw FlowError.routeNotFound
            }
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return
		}
        DispatchQueue.main.async {
            let controller = UIHostingController(rootView: AnyView(view))//.modifier(SwiftUIKitNavigationModifier()))
            self.navigationController?.pushViewController(controller, animated: true)
        }
	}
	
	public func pop() {
        guard let route = routes.last else { return }
        removeRoute(route)
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
	}
	
	public func popToRoot() {
        for route in routes {
            removeRoute(route)
        }
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
	}
	
//	public func navigate(route: String) throws {
//		guard let _ = routes.firstIndex(of: route) else {
//			try push(route: route)
//			return
//		}
//		guard let view = items[route]?() as? any View else {
//			throw FlowError.routeNotFound
//		}
//		let controller = UIHostingController(rootView: AnyView(view))
//		navigationController!.popToViewController(controller, animated: true)
//	}
	
    private func presentView(_ controller: UIViewController) {
        DispatchQueue.main.async {
            let nav = UINavigationController()
            nav.setViewControllers([controller], animated: true)
            nav.modalPresentationStyle = .pageSheet

            if #available(iOS 15.0, *) {
                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.preferredCornerRadius = 48
                }
            }
            self.navigationController!.present(nav, animated: true, completion: nil)
        }
    }
    
    public func present(route: String) throws {
        routes.append(route)

        guard let view = items[route]?() as? any View else {
            guard let controller = items[route]?() as? UIViewController else {
                throw FlowError.routeNotFound
            }
            presentView(controller)
            return
		}

        let controller: UIViewController = UIHostingController(rootView: AnyView(view))
        presentView(controller)
	}
	
	public func dismiss() {
        guard let route = routes.last else { return }
        removeRoute(route)
        DispatchQueue.main.async {
            self.navigationController!.dismiss(animated: true)
            self.onDismiss?()
        }
	}
    
    private func removeRoute(_ route: String) {
        guard let view = items[route]?() as? any FlowViewProtocol else {
            return
        }
        view.events.finish()
        items.removeValue(forKey: route)
        routes.removeLast()
    }
    
    //MARK: - UINavigationControllerDelegate
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let dismissedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
                !navigationController.viewControllers.contains(dismissedViewController) else {
            return
        }
        
        guard let route = routes.last else { return }
        removeRoute(route)
    }
}
#endif
