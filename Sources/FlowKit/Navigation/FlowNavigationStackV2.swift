//
//  FlowNavigationStackV2.swift
//
//
//  Created by Gerardo Grisolini on 13/10/22.
//

import SwiftUI
import Combine
import Resolver

@available(iOS 16.0.0, *)
@MainActor
public class FlowNavigationStackV2: ObservableObject {
    @Injected var navigation: NavigationProtocol

	@Published public var routes: [String] = []
    @Published var presentMode: PresentMode? = nil
    private var cancellables = Set<AnyCancellable>()

	public init() {
		routes = navigation.routes
        navigation.action
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                self?.onChange(action: action)
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
	
	private func onChange(action: NavigationAction) {
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
            if presentMode != nil {
                presentMode = nil
                navigation.routes.popLast()
            }
		}
	}
}
