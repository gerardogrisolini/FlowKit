//
//  FlowNavigationStackV2.swift
//
//
//  Created by Gerardo Grisolini on 13/10/22.
//

import SwiftUI

@available(iOS 16.0, *)
@available(macOS 13.0, *)
final class FlowNavigationStackV2: FlowNavigationStack {

	@Published public var routes: [String] = []

    @MainActor var presentedView: any View {
        switch presentMode {
        case .sheet(let view, _), .fullScreenCover(let view):
            guard let view = view as? any View else {
                guard let vc = view as? UIViewController else {
                    guard let route = view as? any Routable else {
                        return EmptyView()
                    }
                    let routeString = "\(route)"
                    return getView(route: routeString)
                }
                return vc.toSwiftUI()
            }
            return view
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
        default:
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

    @MainActor func getView(route: String) -> AnyView? {
        guard let view = navigation.items[route]?() else { return nil }
		guard let page = view as? any View else {
#if canImport(UIKit)
			guard let vc = view as? UIViewController else {
				return nil
			}
            return AnyView(vc.toSwiftUI().navigationTitle(vc.title ?? "").ignoresSafeArea(.all))
#else
            return nil
#endif
		}
		return AnyView(page)
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
