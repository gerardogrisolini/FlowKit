//
//  RouterStack.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 21/11/24.
//

import SwiftUI
import Combine

class RouterStack: ObservableObject {

    @Published var routes: [String] = []

    @Published
    var presentMode: PresentMode? = nil
    private var cancellables = Set<AnyCancellable>()

    let router: RouterProtocol

    @MainActor
    init(router: RouterProtocol? = nil) {
        self.router = router ?? InjectedValues[\.router]
        self.router.action
            .sink { [weak self] action in
                self?.onChange(action: action)
            }
            .store(in: &cancellables)
    }

    // MARK: - Presentation State Helpers

    var isAlert: Bool {
        get { presentMode?.isAlert ?? false }
        set { presentMode = nil }
    }

    var isConfirmationDialog: Bool {
        get { presentMode?.isConfirmationDialog ?? false }
        set { presentMode = nil }
    }

    @MainActor
    var isSheet: Bool {
        get { presentMode?.isSheet ?? false }
        set { router.dismiss() }
    }

    @MainActor
    var isFullScreenCover: Bool {
        get { presentMode?.isFullScreenCover ?? false }
        set { router.dismiss() }
    }

    var isToast: Bool {
        presentMode?.isToast ?? false
    }

    var isLoader: Bool {
        presentMode?.isLoader ?? false
    }

    var title: String {
        presentMode?.title ?? ""
    }

    // MARK: - View Handling

    @MainActor
    func getView(route: String) -> (any View)? {
        guard let view = router.items.getValue(for: route) else { return nil }
        return convertViewToSwiftUI(view)
    }

    @MainActor
    var presentedView: any View {
        switch presentMode {
        case .sheet(let view, _), .fullScreenCover(let view):
            return convertPresentViewToSwiftUI(view)
        case .alert(title: _, message: let message):
            return Text(message)
        case .confirmationDialog(title: _, actions: let actions):
            return ForEach(actions, id: \.title) { action in
                Button(
                    action.title,
                    role: action.style == .destructive ? .destructive : nil
                ) {
                    action.handler()
                }
            }
        case .toast(message: let message, style: let style, let delay):
            return ToastView(style: style, message: message, dismissDelay: delay) { [onChange] in
                onChange(.dismiss)
            }
        case .loader(style: let style):
            return LoaderView(style: style)
        case .none:
            return EmptyView()
        }
    }

    var presentationDetents: Set<PresentationDetent> {
        switch presentMode {
        case .sheet(_, detents: let detents):
            return Set(detents.map {
                switch $0 {
                case .medium:
                    return PresentationDetent.medium
                case .large:
                    return PresentationDetent.large
                case .fraction(let fraction):
                    return PresentationDetent.fraction(fraction)
                case .height(let height):
                    return PresentationDetent.height(height)
                }
            })
        default:
            return []
        }
    }

    // MARK: - Action Handling

    func onChange(action: RouterAction) {
        switch action {
        case .navigate(route: let route):
            routes.append(route)

        case .pop(route: let route):
            guard routes.last == route else { return }
            routes.removeLast()

        case .popToRoot:
            routes = []

        case .present(let mode):
            presentMode = mode

        case .dismiss:
            presentMode = nil
        }
    }

}

// MARK: - Helpers for PresentMode Parsing

private extension PresentMode {

    var isAlert: Bool {
        if case .alert(_, _) = self { return true }
        return false
    }

    var isConfirmationDialog: Bool {
        if case .confirmationDialog(_, _) = self { return true }
        return false
    }

    var isSheet: Bool {
        if case .sheet(_, _) = self { return true }
        return false
    }

    var isFullScreenCover: Bool {
        if case .fullScreenCover(_) = self { return true }
        return false
    }

    var isToast: Bool {
        if case .toast(_, _, _) = self { return true }
        return false
    }

    var isLoader: Bool {
        if case .loader(_) = self { return true }
        return false
    }

    var title: String? {
        switch self {
        case .alert(let title, _), .confirmationDialog(let title, _):
            return title
        default:
            return nil
        }
    }
}

// MARK: - View Conversion Helper

extension RouterStack {

    @MainActor
    func convertViewToSwiftUI(_ view: Any) -> (any View)? {
        switch view {
        case let view as (any View):
            return view
#if canImport(UIKit) && !os(visionOS)
        case let vc as UIViewController:
            return vc.toSwiftUI()
                .navigationTitle(vc.title ?? "")
                .edgesIgnoringSafeArea(.all)
#endif
        default:
            return nil
        }
    }

    @MainActor
    func convertPresentViewToSwiftUI(_ view: Any) -> any View {
        switch view {
        case let view as any View:
            return view
        case let route as any Routable:
            let routeString = route.routeString
            return getView(route: routeString) ?? EmptyView()
#if canImport(UIKit) && !os(visionOS)
        case let vc as UIViewController:
            return vc.toSwiftUI()
#endif
        default:
            return EmptyView()
        }
    }
}
