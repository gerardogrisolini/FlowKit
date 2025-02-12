//
//  RouterStackV2.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 13/10/22.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 16.0, *)
@available(macOS 13.0, *)
final class RouterStackV2: RouterStack {

    @Published public var routes: [String] = []

    // MARK: - Presentation View

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
        default: return []
        }
    }

    // MARK: - Action Handling

    override func onChange(action: RouterAction) {
        switch action {
        case .navigate(route: let route):
            guard routes.last != route else { return }
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
