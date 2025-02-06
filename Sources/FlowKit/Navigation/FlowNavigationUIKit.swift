//
//  NavigationUIKit.swift
//
//
//  Created by Gerardo Grisolini on 11/10/22.
//


#if canImport(UIKit)
import UIKit
import SwiftUI
import Combine

final class FlowNavigationUIKit: NavigationUIKit {

    override public func popToFlow() {
        var count = routes.count - 1
        while count >= 0 {
            let route = routes[count]
            if items.getValue(for: route) is any FlowProtocol {
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

        let view = items.getValue(for: route)

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

    private func removeRoute(_ route: String) {
        let view = items.getValue(for: route)

        if let index = routes.firstIndex(of: route) {
            routes.remove(at: index)
        }

        if let view = view as? any FlowViewProtocol {
            view.events.finish()
        }

        items.remove(route)
    }
    
    //MARK: - UINavigationControllerDelegate
    override func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let dismissedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
                !navigationController.viewControllers.contains(dismissedViewController) else {
            return
        }

        guard let route = routes.last else { return }

        removeRoute(route)

        guard let route = routes.last else { return }

        if items.getValue(for: route) is any FlowProtocol {
            routes.removeLast()
        }
    }
}
#endif

