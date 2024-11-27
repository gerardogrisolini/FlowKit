//
//  FlowNavigationswift
//  FlowKit
//
//  Created by Gerardo Grisolini on 21/11/24.
//

import SwiftUI
import Combine
import Resolver

class FlowNavigationStack: ObservableObject {

    var navigation: NavigationProtocol
    @Published var presentMode: PresentMode? = nil
    @Published var view: (any View)?
    @Published var presentedView: any View = EmptyView()
    private var cancellables = Set<AnyCancellable>()

    var isAlert: Bool {
        guard let mode = presentMode, case .alert(title: _, message: _) = mode else { return false }
        return true
    }
    var isConfirmationDialog: Bool {
        guard let mode = presentMode, case .confirmationDialog(title: _, actions: _) = mode else { return false }
        return true
    }
    var isSheet: Bool {
        guard let mode = presentMode, case .sheet(_, _) = mode else { return false }
        return true
    }
    var isFullScreenCover: Bool {
        guard let mode = presentMode, case .fullScreenCover(_) = mode else { return false }
        return true
    }

    var title: String {
        switch presentMode {
        case .alert(title: let title, _), .confirmationDialog(title: let title, _):
            return title
        default: return ""
        }
    }

    @MainActor init(navigation nav: NavigationProtocol? = nil) {
        navigation = nav ?? Resolver.resolve()
        navigation.action
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                self?.onChange(action: action)
            }
            .store(in: &cancellables)
    }

    open func onChange(action: NavigationAction) { }
}
