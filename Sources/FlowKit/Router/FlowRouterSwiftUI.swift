//
//  FlowRouterSwiftUI.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 11/10/22.
//

import SwiftUI
import Combine
import NavigationKit

final class FlowRouterSwiftUI: RouterSwiftUI {

    /// Pops all view controllers until it reaches the starting point of a navigation flow.
    /// This iterates through the stack, removing routes and sending `.pop` actions.
    public func popToFlow() {
        while let route = routes.popLast() {
            removeRoute(route)

            if items.getValue(for: route) is any FlowProtocol {
                break
            }

            action.send(.pop(route))
        }
    }

    /// Remove route from the stack and terminates the sequence of events.
    override public func removeRoute(_ route: String) {
        let view = items.getValue(for: route)

        if let view = view as? any FlowViewProtocol {
            view.events.finish()
        }

        items.remove(route)
    }

}
