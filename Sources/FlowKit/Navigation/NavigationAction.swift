//
//  NavigationAction.swift
//
//
//  Created by Gerardo Grisolini on 12/10/22.
//

/// NavigationAction is the enum that contains the navigation actions
public enum NavigationAction: Identifiable, Equatable, Sendable {
    case navigate(String)
    case present(PresentMode)
    case pop(String)
    case popToRoot
    case dismiss

    public var id: String {
        String(describing: self)
    }

    public static func == (lhs: NavigationAction, rhs: NavigationAction) -> Bool {
        lhs.id == rhs.id
    }
}

