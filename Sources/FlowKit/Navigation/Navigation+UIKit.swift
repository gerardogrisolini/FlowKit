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

public final class NavigationUIKit: NSObject, NavigationProtocol, UINavigationControllerDelegate {

    public var navigationController: UINavigationController? {
        didSet {
            navigationController?.delegate = self
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
	public var action = PassthroughSubject<NavigationAction, Never>()
    public var routes: [String] = []
	public var items = NavigationItems()
    public var presentMode: PresentMode? = nil


    public func navigate(routeString: String) async {
        try? await push(route: routeString)
    }

    public func navigate(route: some Routable) async throws {
        try await push(route: route.routeString)
    }

    public func push(route: String) async throws {
        guard !routes.contains(route) else { return }
        routes.append(route)

        guard let view = await items.getValue(for: route) as? any View else {
            guard let vc = await items.getValue(for: route) as? UIViewController else {
                throw FlowError.routeNotFound
            }
            navigationController?.pushViewController(vc, animated: true)
            return
		}
        let controller = UIHostingController(rootView: AnyView(view))//.modifier(SwiftUIKitNavigationModifier()))
        navigationController?.pushViewController(controller, animated: true)
	}
	
	public func pop() async {
        guard let route = routes.last else { return }
        await removeRoute(route)
        navigationController?.popViewController(animated: true)
	}
	
    public func popToFlow() async {
        var count = routes.count - 1
        while count >= 0 {
            let route = routes[count]
            if await items.getValue(for: route) is any FlowProtocol {
                routes.removeLast()
                break
            }
            await removeRoute(route)
            count -= 1
        }

        guard let route = routes.last else {
            await popToRoot()
            return
        }

        let view = await items.getValue(for: route)

        guard view is any View else {
            return
        }

        guard let vc = navigationController?.viewControllers[routes.count - 1] else {
            await popToRoot()
            return
        }

        navigationController?.popToViewController(vc, animated: true)
        return
    }

    public func popToRoot() async {
        for route in routes {
            await removeRoute(route)
        }
        navigationController?.popToRootViewController(animated: true)
	}

    private func presentView(_ controller: UIViewController, detents: [UISheetPresentationController.Detent]) {
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

    public func present(_ mode: PresentMode) {
        presentMode = mode

        if let routeString = mode.routeString {
            routes.append(routeString)
        }

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
        if let mode = presentMode {
            navigationController?.dismiss(animated: true)

            if let routeString = mode.routeString {
                routes.removeAll(where: { $0 == routeString })
            }
            presentMode = nil
        }
	}
    
    private func removeRoute(_ route: String) async {
        let view = await items.getValue(for: route)

        if let index = routes.firstIndex(of: route) {
            routes.remove(at: index)
        }

        if let view = view as? any FlowViewProtocol {
            view.events.finish()
        }

        guard view is any FlowProtocol else {
            await items.remove(route)
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

        Task { @MainActor in
            await removeRoute(route)

            guard let route = routes.last else { return }

            if await items.getValue(for: route) is any FlowProtocol {
                routes.removeLast()
            }
        }
    }
}
#endif
