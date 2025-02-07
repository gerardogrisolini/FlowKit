//
//  NavigationSwiftUIStackV1.swift
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
final class NavigationSwiftUIStackV1: NavigationSwiftUIStack {

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
        case .toast(message: let message, style: let style, dismissDelay: let delay):
            return ToastView(style: style, message: message, dismissDelay: delay) { [onChange] in
                onChange(.dismiss)
            }
        default:
            return EmptyView()
        }
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
