//
//  FlowNavigationStackV1.swift
//
//
//  Created by Gerardo Grisolini on 15/10/22.
//

import SwiftUI
import Combine
import Resolver

@MainActor
public class FlowNavigationStackV1: ObservableObject {
    @Injected var navigation: NavigationProtocol

    @Published var route: String? = nil
    @Published public var presentedView: (any View)? = nil
    private var cancellables: [AnyCancellable] = []
    
    var view: AnyView? {
		guard let route, let view = navigation.items[route]?() else { return nil }
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
    
    public init() {
        navigation.action
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                self?.onChange(action: action)
            }
            .store(in: &cancellables)
    }

    private func onChange(action: NavigationAction) {
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

        case .present(let route):
            guard self.route == navigation.routes.last else { return }
            guard let page = navigation.items[route]?() as? any View else { return }
            presentedView = page

        case .dismiss:
            if presentedView != nil {
                presentedView = nil
            }
        }
    }
}
