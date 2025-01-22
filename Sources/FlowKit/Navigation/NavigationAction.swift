//
//  NavigationAction.swift
//
//
//  Created by Gerardo Grisolini on 12/10/22.
//

import SwiftUI

/// NavigationAction is the enum that contains the navigation actions
public enum NavigationAction: Identifiable, Equatable, Sendable {
    case navigate(String)
    case present(PresentMode)
    case pop(String)
    case popToRoot
    case dismiss

    public var id: String {
        String(describing: type(of: self))
    }

    public static func == (lhs: NavigationAction, rhs: NavigationAction) -> Bool {
        lhs.id == rhs.id
    }
}

/// Presentation modes
public enum PresentMode: Identifiable, Sendable, Equatable {
    case alert(title: String = "", message: String = "")
    case confirmationDialog(title: String = "", actions: [AlertAction])
    case sheet(any Sendable, detents: [PresentationDetents] = [.medium, .large])
    case fullScreenCover(any Sendable)
    case toast(message: String, style: ToastStyle, dismissDelay: Double = 3.0)

    public var id: String { "\(self)" }

    var routeString: String? {
        switch self {
        case .toast, .alert, .confirmationDialog: return nil
        case .sheet(let view, let detents): return "sheet-\(view)-\(String(describing: detents))"
        case .fullScreenCover(let view): return "fullScreenCover-\(view)"
        }
    }

    public static func == (lhs: PresentMode, rhs: PresentMode) -> Bool {
        lhs.id == rhs.id
    }
}
