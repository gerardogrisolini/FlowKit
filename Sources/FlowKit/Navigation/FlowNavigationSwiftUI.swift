//
//  FlowNavigationSwiftUI.swift
//
//
//  Created by Gerardo Grisolini on 11/10/22.
//

import SwiftUI
import Combine
import NavigationKit

final class FlowNavigationSwiftUI: NavigationSwiftUI {

    override public func removeRoute(_ route: String) {
        let view = items.getValue(for: route)

        if let view = view as? any FlowViewProtocol {
            view.events.finish()
        }

        guard view is any FlowProtocol else {
            items.remove(route)
            return
        }
    }

    override public func popToFlow() {
        while let route = routes.popLast() {
            removeRoute(route)

            if items.getValue(for: route) is any FlowProtocol {
                break
            }

            action.send(.pop(route))
		}
	}
}
