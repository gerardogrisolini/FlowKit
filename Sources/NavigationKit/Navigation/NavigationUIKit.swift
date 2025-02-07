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

//
//  NavigationUIKit.swift
//
//  Created by Gerardo Grisolini on 11/10/22.
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import Combine

/// A navigation handler class that integrates `UINavigationController`
/// with SwiftUI and provides a flexible navigation system.
open class NavigationUIKit: NSObject, NavigationProtocol {

    /// The main navigation controller used to manage the navigation stack.
    public var navigationController: UINavigationController? {
        didSet {
            // Set the navigation controller delegate to self to handle navigation events
            navigationController?.delegate = self
            // Enable large titles in the navigation bar for better UI/UX
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    /// A publisher that allows for reactive handling of navigation actions.
    public let action = PassthroughSubject<NavigationAction, Never>()

    /// Stores the list of active routes in the navigation stack.
    public var routes: [String] = []

    /// Stores navigation items mapped to their respective routes.
    public var items = NavigationItems()

    /// Stores the current presentation mode (modal, sheet, etc.), if any.
    public var presentMode: PresentMode? = nil

    /// Navigates to a given route string by pushing it onto the navigation stack.
    /// - Parameter routeString: The string identifier for the navigation route.
    public func navigate(routeString: String) {
        push(route: routeString)
    }

    /// Navigates using a `Routable` object, ensuring the route exists.
    /// - Parameter route: The route conforming to `Routable`.
    /// - Throws: `NavigationError.routeNotFound` if the route is not found in items.
    public func navigate(route: some Routable) throws {
        let routeString = route.routeString
        guard items.setParam(for: routeString, param: route.associated.value) else {
            throw NavigationError.routeNotFound
        }
        push(route: routeString)
    }

    /// Pushes a view controller or SwiftUI view onto the navigation stack.
    /// - Parameter route: The string identifier of the route to navigate to.
    public func push(route: String) {
        // Avoid duplicate routes in the stack
        guard !routes.contains(route) else { return }
        routes.append(route)

        // Attempt to retrieve a UIViewController from stored navigation items
        guard let vc = items.getValue(for: route) as? UIViewController else {

            // If it's not a UIViewController, check if it's a SwiftUI view
            guard let view = items.getValue(for: route) as? any View else {
                return
            }

            // Convert the SwiftUI view to UIKit and push it onto the stack
            navigationController?.pushViewController(view.toUIKit(), animated: true)
            return
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    /// Pops the top view controller off the navigation stack.
    public func pop() {
        guard let route = routes.last else { return }
        removeRoute(route)
        navigationController?.popViewController(animated: true)
    }

    /// Pops view controllers until it reaches the flow's starting point.
    open func popToFlow() {
        var count = routes.count - 1
        while count >= 0 {
            let route = routes[count]
            removeRoute(route)
            count -= 1
        }

        // Ensure at least one valid route exists
        guard let route = routes.last else {
            popToRoot()
            return
        }

        // Retrieve the last route's view
        let view = items.getValue(for: route)

        // If the last item is not a SwiftUI View, return
        guard view is any View else {
            return
        }

        // Find the corresponding view controller in the stack and pop to it
        guard let vc = navigationController?.viewControllers[routes.count - 1] else {
            popToRoot()
            return
        }

        navigationController?.popToViewController(vc, animated: true)
    }

    /// Pops all view controllers and returns to the root.
    public func popToRoot() {
        for route in routes {
            removeRoute(route)
        }
        navigationController?.popToRootViewController(animated: true)
    }

    /// Presents a view controller as a modal sheet with specified detents.
    /// - Parameters:
    ///   - controller: The view controller to be presented.
    ///   - detents: The height options for the modal sheet.
    private func presentView(_ controller: UIViewController, detents: [UISheetPresentationController.Detent]) {
        controller.modalPresentationStyle = .pageSheet

        if #available(iOS 15.0, *) {
            if let sheet = controller.sheetPresentationController {
                sheet.detents = detents
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.preferredCornerRadius = 48
            }
        }
        navigationController?.present(controller, animated: true, completion: { [dismiss] in dismiss() })
    }

    /// Presents a modal view based on the given `PresentMode`.
    /// - Parameter mode: The mode defining the type of presentation.
    public func present(_ mode: PresentMode) {
        presentMode = mode

        if let routeString = mode.routeString {
            routes.append(routeString)
        }

        switch mode {
        case .toast(message: let message, style: let style, dismissDelay: let delay):
            let view = ToastView(style: style, message: message, dismissDelay: delay, onCancelTapped: { [dismiss] in dismiss() })
            navigationController?.present(view.toUIKit(), animated: true)

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
            navigationController?.present(controller, animated: true, completion: { [dismiss] in dismiss() })
        }
    }

    /// Dismisses the currently presented modal view.
    public func dismiss() {
        if let mode = presentMode {
            navigationController?.dismiss(animated: true)

            if let routeString = mode.routeString {
                routes.removeAll(where: { $0 == routeString })
            }
            presentMode = nil
        }
    }

    /// Removes a route from the navigation stack and its associated view.
    /// - Parameter route: The route string to be removed.
    private func removeRoute(_ route: String) {
        if let index = routes.firstIndex(of: route) {
            routes.remove(at: index)
        }
        items.remove(route)
    }
}

// MARK: - UINavigationControllerDelegate

extension NavigationUIKit: UINavigationControllerDelegate {

    /// Called when a view controller is about to be shown.
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let dismissedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
                !navigationController.viewControllers.contains(dismissedViewController) else {
            return
        }

        guard let route = routes.last else { return }

        removeRoute(route)
    }
}
#endif
