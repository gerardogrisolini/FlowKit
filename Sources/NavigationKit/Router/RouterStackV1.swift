//
//  RouterStackV1.swift
//  NavigationKit
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
final class RouterStackV1: RouterStack {

    @Published var route: String? = nil

    // MARK: - Presentation State Helpers

    @MainActor
    var presentedView: any View {
        switch presentMode {
        case .sheet(let view, _), .fullScreenCover(let view):
            return convertPresentViewToSwiftUI(view)
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
        case .loader(style: let style):
            return LoaderView(style: style)
        default:
            return EmptyView()
        }
    }

    // MARK: - Action Handling

    override func onChange(action: RouterAction) {
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
