//
//  RouterUIKit.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 11/10/22.
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import Combine

/// A router handler class that integrates `UINavigationController`
/// with SwiftUI and provides a flexible navigation system.
open class RouterUIKit: NSObject, RouterProtocol {

    /// The main navigation controller used to manage the navigation stack.
    public var navigationController: UINavigationController? {
        didSet {
            // Set the navigation controller delegate to self to handle navigation events
            navigationController?.delegate = self
            // Enable large titles in the navigation bar for better UI/UX
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    /// A publisher that allows for reactive handling of router actions.
    public let action = PassthroughSubject<RouterAction, Never>()

    /// Stores the list of active routes in the navigation stack.
    public var routes: [String] = []

    /// Stores router items mapped to their respective routes.
    public var items = RouterItems()

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
        if let view = route.view {
            items.setValue(for: routeString, value: { _ in view })
        } else if !items.setParam(for: routeString, param: route.associated.value) {
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
        guard let view = items.getValue(for: route), let vc = convertViewToUIKit(view) else { return }
        navigationController?.pushViewController(vc, animated: true)
    }

    /// Pops the top view controller off the navigation stack.
    public func pop() {
        guard let route = routes.last else { return }
        removeRoute(route)
        navigationController?.popViewController(animated: true)
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
        navigationController?.present(controller, animated: true)
    }

    /// Presents a modal view based on the given `PresentMode`.
    /// - Parameter mode: The mode defining the type of presentation.
    public func present(_ mode: PresentMode) {
        presentMode = mode

        if let routeString = mode.routeString {
            routes.append(routeString)
        }

        switch mode {
        case .alert(title: let title, message: let message):
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            navigationController?.present(alert, animated: true)

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
            navigationController?.present(alert, animated: true)

        case .sheet(let view, let detents):
            let controller = convertPresentedViewToUIKit(view)
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
            let controller = convertPresentedViewToUIKit(view)
            controller.modalPresentationStyle = .fullScreen
            navigationController?.present(controller, animated: true)

        case .toast(message: let message, style: let style, dismissDelay: let delay):
            let view = ToastView(style: style, message: message, dismissDelay: delay, onCancelTapped: { [dismiss] in dismiss() })
            navigationController?.present(view.toUIKit(), animated: true)

        case .loader(style: let style):
            addLoader(style: style)
        }
    }

    /// Dismisses the currently presented modal view.
    public func dismiss() {
        if let mode = presentMode {
            navigationController?.dismiss(animated: true)

            if let routeString = mode.routeString {
                routes.removeAll(where: { $0 == routeString })
            }
            else if let loader = navigationController?.view.subviews.first(where: { $0.tag == -999 }) {
                loader.removeFromSuperview()
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

    /// Adds a loader view to the current navigation controller's view with specified style.
    ///
    /// This method creates a `LoaderView` instance with the given `LoaderStyle` and converts it
    /// to a UIKit compatible view. The loader view is assigned a unique tag for identification
    /// and its background color is set to clear. It is added as a subview to the navigation controller's view,
    /// and its constraints are set to occupy the full bounds of the parent view.
    ///
    /// - Parameter style: The style for the loader view.
    private func addLoader(style: LoaderStyle) {
        guard let view = navigationController?.view else { return }

        let loaderView = LoaderView(style: style).toUIKit().view!
        loaderView.tag = -999
        loaderView.backgroundColor = .clear
        view.addSubview(loaderView)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        loaderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loaderView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

// MARK: - UINavigationControllerDelegate
extension RouterUIKit: UINavigationControllerDelegate {

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

// MARK: - View Conversion Helper
extension RouterUIKit {

    @MainActor
    func convertViewToUIKit(_ view: Any) -> UIViewController? {
        switch view {
        case let vc as UIViewController:
            return vc
        case let ui as any View:
            return ui.toUIKit()
        default:
            return nil
        }
    }

    @MainActor
    func convertPresentedViewToUIKit(_ view: Any) -> UIViewController {
        switch view {
        case let vc as UIViewController:
            return vc

        case let route as any Routable:
            if let v = items.getValue(for: route.routeString), let vc = convertViewToUIKit(v) {
                return vc
            }

        case let ui as any View:
            return ui.toUIKit()

        default:
            break
        }

        return UIViewController()
    }
}
#endif
