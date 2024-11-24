//
//  FlowNavigationStackV1.swift
//
//
//  Created by Gerardo Grisolini on 15/10/22.
//

import SwiftUI

@available(iOS 14.0, *)
@available(iOS, deprecated: 16.0)
@available(macOS, deprecated: 13.0)
final class FlowNavigationStackV1: FlowNavigationStack {

    @Published var route: String? = nil

    @MainActor func setPresentedView() async {
        switch presentMode {
        case .sheet(let view, _), .fullScreenCover(let view):
            guard let view = view as? any View else {
                guard let vc = view as? UIViewController else {
                    presentedView = EmptyView()
                    return
                }
                presentedView = vc.toSwiftUI()
                return
            }
            presentedView = view
        case .alert(title: _, message: let message):
            presentedView = Text(message)
        case .confirmationDialog(title: _, actions: let actions):
            presentedView = ForEach(actions, id: \.title) { action in
                Button(action.title) { action.handler() }
            }
        default:
            presentedView = EmptyView()
        }
    }

    @MainActor func setView(route: String) async {
        view = await getView(route: route)
    }

    @MainActor private func getView(route: String) async -> (any View)? {
        guard let view = await navigation.items.getValue(for: route) else { return nil }
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
