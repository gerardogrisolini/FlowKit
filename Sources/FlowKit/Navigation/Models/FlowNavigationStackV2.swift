//
//  FlowNavigationStackV2.swift
//  FlowCommon
//
//  Created by Gerardo Grisolini on 13/10/22.
//

import SwiftUI
import Combine
import Resolver

public class FlowNavigationStackV2: ObservableObject {

	@Injected var navigation: NavigationProtocol
	
	@Published public var routes: [String] = []
	@Published public var presentedView: (any View)? = nil
    private var cancellables = Set<AnyCancellable>()

	public init() {
		routes = navigation.routes
        navigation.action
            .eraseToAnyPublisher()
            .sink { action in
                Task {
                    await self.onChange(action: action)
                }
            }
            .store(in: &cancellables)
	}
	
	func view(route: String) -> AnyView? {
		guard let view = navigation.items[route]?() else { return nil }
		guard let page = view as? any View else {
#if canImport(UIKit)
			guard let vc = view as? UIViewController else {
				return nil
			}
			return AnyView(vc.toSwiftUI().navigationTitle(vc.title ?? ""))
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
	
	@MainActor
	private func onChange(action: NavigationAction) {
		switch action {
		case .navigate(route: let route):
			navigate(route: route)

		case .pop(route: let route):
			pop(route: route)

		case .popToRoot:
			popToRoot()
			
		case .present(let route):
            guard let page = navigation.items[route]?() as? any View else {
#if canImport(UIKit)
                guard let page = navigation.items[route]?() as? UIViewController else {
                    return
                }
                presentedView = page.toSwiftUI()
#endif
                return
            }
			presentedView = page
			
		case .dismiss:
			presentedView = nil
		}
	}
}
