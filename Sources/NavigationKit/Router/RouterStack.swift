//
//  RouterStack
//  NavigationKit
//
//  Created by Gerardo Grisolini on 21/11/24.
//

import SwiftUI
import Combine

class RouterStack: ObservableObject {

    var router: RouterProtocol
    @Published var presentMode: PresentMode? = nil
    private var cancellables = Set<AnyCancellable>()

    var isAlert: Bool {
        get {
            guard let mode = presentMode, case .alert(title: _, message: _) = mode else { return false }
            return true
        }
        set { presentMode = nil }
    }

    var isConfirmationDialog: Bool {
        get {
            guard let mode = presentMode, case .confirmationDialog(title: _, actions: _) = mode else { return false }
            return true
        }
        set { presentMode = nil }
    }

    @MainActor var isSheet: Bool {
        get {
            guard let mode = presentMode, case .sheet(_, _) = mode else { return false }
            return true
        }
        set { router.dismiss() }
    }

    @MainActor var isFullScreenCover: Bool {
        get {
            guard let mode = presentMode, case .fullScreenCover(_) = mode else { return false }
            return true
        }
        set { router.dismiss() }
    }

    var isToast: Bool {
        guard let mode = presentMode, case .toast(message: _, style: _, dismissDelay: _) = mode else { return false }
        return true
    }

    var title: String {
        switch presentMode {
        case .alert(title: let title, _), .confirmationDialog(title: let title, _):
            return title
        default: return ""
        }
    }

    @MainActor init(router r: RouterProtocol? = nil) {
        router = r ?? InjectedValues[\.router]
        router.action
            .sink { [onChange] action in
                onChange(action)
            }
            .store(in: &cancellables)
    }

    @MainActor
    func getView(route: String) -> (any View)? {
        guard let view = router.items.getValue(for: route) else { return nil }
        guard let page = view as? any View else {
#if canImport(UIKit)
            guard let vc = view as? UIViewController else {
                return nil
            }
            let swiftUI = vc.toSwiftUI()
            return swiftUI
                .navigationTitle(vc.title ?? "")
                .edgesIgnoringSafeArea(.all)
#else
            return nil
#endif
        }
        return page
    }

    open func onChange(action: RouterAction) { }
}
