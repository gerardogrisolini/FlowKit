//
//  FlowNavigationStackV2.swift
//
//
//  Created by Gerardo Grisolini on 13/10/22.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 16.0, *)
@available(macOS 13.0, *)
final class FlowNavigationStackV2: FlowNavigationStack {

	@Published public var routes: [String] = []

    @MainActor func setPresentedView() async {
        switch presentMode {
        case .sheet(let view, _), .fullScreenCover(let view):
            guard let view = view as? any View else {
                guard let route = view as? any Routable else {
#if canImport(UIKit)
                    guard let vc = view as? UIViewController else {
                        presentedView = EmptyView()
                        return
                    }
                    presentedView = vc.toSwiftUI()
#else
                    presentedView = EmptyView()
#endif
                    return
                }
                let routeString = route.routeString
                presentedView = await getView(route: routeString) ?? EmptyView()
                return
            }
            presentedView = view
        case .alert(title: _, message: let message):
            presentedView = Text(message)
        case .confirmationDialog(title: _, actions: let actions):
            presentedView = ForEach(actions, id: \.title) { action in
                Button(
                    action.title,
                    role: action.style == .destructive ? .destructive : nil
                ) {
                    action.handler()
                }
            }
        default:
            presentedView = EmptyView()
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
            return vc.toSwiftUI().navigationTitle(vc.title ?? "").ignoresSafeArea(.all)
#else
            return nil
#endif
		}
		return page
	}
	
	private func navigate(route: String) {
		guard routes.last != route else { return }
		routes.append(route)
	}
	
	private func pop(route: String) {
		guard routes.last == route else { return }
		routes.removeLast()
	}

    private func popToRoot() {
		routes = []
	}
	
    override func onChange(action: NavigationAction) {
		switch action {
		case .navigate(route: let route):
			navigate(route: route)

		case .pop(route: let route):
			pop(route: route)

		case .popToRoot:
			popToRoot()
			
		case .present(let mode):
            presentMode = mode

		case .dismiss:
            presentMode = nil
		}
	}
}
