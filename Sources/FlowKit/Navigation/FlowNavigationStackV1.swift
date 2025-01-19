//
//  FlowNavigationStackV1.swift
//
//
//  Created by Gerardo Grisolini on 15/10/22.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 14.0, *)
@available(iOS, deprecated: 16.0)
@available(macOS, deprecated: 13.0)
final class FlowNavigationStackV1: FlowNavigationStack {

    @Published var route: String? = nil

    @MainActor
    var presentedView: any View {
        switch presentMode {
        case .sheet(let view, _), .fullScreenCover(let view):
            guard let view = view as? any View else {
                guard let route = view as? any Routable else {
#if canImport(UIKit)
                    guard let vc = view as? UIViewController else {
                        return EmptyView()
                    }
                    return vc.toSwiftUI()
#else
                    return EmptyView()
#endif
                }
                let routeString = route.routeString
                return getView(route: routeString) ?? EmptyView()
            }
            return view
        case .alert(title: _, message: let message):
            return Text(message)
        case .confirmationDialog(title: _, actions: let actions):
            return ForEach(actions, id: \.title) { action in
                Button(action.title) { action.handler() }
            }
        case .toast(message: let message, style: let style):
            return ToastView(style: style, message: message) { [onChange] in
                onChange(.dismiss)
            }
        default:
            return EmptyView()
        }
    }


    @MainActor func getView(route: String) -> (any View)? {
        guard let view = navigation.items.getValue(for: route) else { return nil }
        guard let page = view as? any View else {
#if canImport(UIKit)
            guard let vc = view as? UIViewController else {
                return nil
            }
            return vc.toSwiftUI().navigationTitle(vc.title ?? "")
#else
            return nil
#endif
        }
        return page
    }

    override func onChange(action: NavigationAction) {
        switch action {
        case .navigate(route: let route):
            if self.route == nil {
                self.route = route
            }

        case .pop(let route):
            if self.route == route {
                self.route = nil
            }

        case .popToRoot:
            route = nil

        case .present(let mode):
            presentMode = mode

        case .dismiss:
            presentMode = nil
        }
    }
}
