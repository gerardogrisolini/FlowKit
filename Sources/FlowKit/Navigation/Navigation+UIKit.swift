//
//  NavigationUIKit.swift
//
//
//  Created by Gerardo Grisolini on 11/10/22.
//

import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit

@MainActor
public final class NavigationUIKit: NSObject, NavigationProtocol, UINavigationControllerDelegate {
    public typealias Navigable = UIViewController

    public var navigationController: UINavigationController? {
        didSet {
            navigationController?.delegate = self
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
	public var action = PassthroughSubject<NavigationAction, Never>()
    public var routes: [String] = []
	public var items = NavigationItems()


    public func navigate(routeString: String) {
        try? push(route: routeString)
    }

    public func navigate(route: some Routable) throws {
        try push(route: "\(route)")
    }
    
    public func present(route: some Routable) throws {
        try present(route: "\(route)")
    }
    
    public func push(route: String) throws {
        guard !routes.contains(route) else { return }
        routes.append(route)

        guard let view = items[route]?() as? any View else {
            guard let vc = items[route]?() as? UIViewController else {
                throw FlowError.routeNotFound
            }
            navigationController?.pushViewController(vc, animated: true)
            return
		}
        let controller = UIHostingController(rootView: AnyView(view))//.modifier(SwiftUIKitNavigationModifier()))
        navigationController?.pushViewController(controller, animated: true)
	}
	
	public func pop() {
        guard let route = routes.last else { return }
        removeRoute(route)
        navigationController?.popViewController(animated: true)
	}
	
    public func popToFlow() {
        var count = routes.count - 1
        while count >= 0 {
            let route = routes[count]
            if items[route]?() is any FlowProtocol {
                routes.removeLast()
                break
            }
            removeRoute(route)
            count -= 1
        }

        guard let route = routes.last else {
            popToRoot()
            return
        }

        let view = items[route]?()

        guard view is any View else {
            return
        }

        guard let vc = navigationController?.viewControllers[routes.count - 1] else {
            popToRoot()
            return
        }

        navigationController?.popToViewController(vc, animated: true)
        return
    }

    public func popToRoot() {
        for route in routes {
            removeRoute(route)
        }
        navigationController?.popToRootViewController(animated: true)
	}

    private func presentView(_ controller: UIViewController, detents: [UISheetPresentationController.Detent] = [.medium(), .large()]) {
        controller.modalPresentationStyle = .pageSheet

        if #available(iOS 15.0, *) {
            if let sheet = controller.sheetPresentationController {
                sheet.detents = detents
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.preferredCornerRadius = 48
            }
        }
        navigationController?.present(controller, animated: true, completion: dismiss)
    }
    
    private func present(route: String) throws {
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

    public func present(_ mode: PresentMode) {
        let routeString = String(describing: mode)
        routes.append(routeString)

        switch mode {
        case .alert(title: let title, message: let message):
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            navigationController?.present(alert, animated: true, completion: nil)

        case .confirmationDialog(title: let title, actions: let actions):
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            actions.forEach { item in
                alert.addAction(UIAlertAction(
                    title: item.title,
                    style: UIAlertAction.Style(rawValue: item.style.rawValue) ?? .default,
                    handler: { _ in
                        item.handler()
                    }
                ))
            }
            navigationController?.present(alert, animated: true, completion: nil)

        case .sheet(let view, let detents):
            guard let controller = view as? UIViewController else { return }
            let detentsMapped: [UISheetPresentationController.Detent] = detents.map {
                switch $0 {
                case .large:
                    return UISheetPresentationController.Detent.large()
                default:
                    return UISheetPresentationController.Detent.medium()
                }
            }
            presentView(controller, detents: detentsMapped)

        case .fullScreenCover(let view):
            guard let controller = view as? UIViewController else { return }
            controller.modalPresentationStyle = .fullScreen
            navigationController?.present(controller, animated: true, completion: dismiss)
        }
    }

	public func dismiss() {
        let styles: [UIModalPresentationStyle] = [.fullScreen, .pageSheet, .overFullScreen]
        if let style = navigationController?.modalPresentationStyle, styles.contains(style) {
            navigationController?.dismiss(animated: true)
            guard let route = routes.last else { return }
            removeRoute(route)
//        } else {
//            navigationController?.popViewController(animated: true)
        }
	}
    
    private func removeRoute(_ route: String) {
        let view = items[route]?()

        if let index = routes.firstIndex(of: route) {
            routes.remove(at: index)
        }

        if let view = view as? any FlowViewProtocol {
            view.events.finish()
        }

        guard view is any FlowProtocol else {
            items.remove(route)
            return
        }
    }
    
    //MARK: - UINavigationControllerDelegate
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let dismissedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
                !navigationController.viewControllers.contains(dismissedViewController) else {
            return
        }
        
        guard let route = routes.last else { return }
        removeRoute(route)

        guard let route = routes.last else { return }

        if items[route]?() is any FlowProtocol {
            routes.removeLast()
        }
    }
}
#endif
