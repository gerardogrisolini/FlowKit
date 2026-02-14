//
//  RouterAction.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 12/10/22.
//

import SwiftUI

/// This enumeration defines various actions that a router can perform in a navigation system.
public enum RouterAction: Identifiable, Equatable, Sendable {

    /// Navigate to a different view or screen, specified by a string identifier.
    case navigate(String)

    /// Present a new view in a specific mode, described by the PresentMode type.
    case present(PresentMode)

    /// Pop back to a previous view, identified by a string.
    case pop(String)

    /// Pop back to the root of the navigation stack.
    case popToRoot

    /// Dismiss the current view.
    case dismiss

    /// Property that uniquely identifies each RouterAction instance.
    public var id: String {
        switch self {
        case .navigate(let route):
            return "navigate:\(route)"
        case .present(let mode):
            return "present:\(mode.id)"
        case .pop(let route):
            return "pop:\(route)"
        case .popToRoot:
            return "popToRoot"
        case .dismiss:
            return "dismiss"
        }
    }

    /// Checks if two RouterAction instances are equal, based on their ids.
    public static func == (lhs: RouterAction, rhs: RouterAction) -> Bool {
        switch (lhs, rhs) {
        case (.navigate(let l), .navigate(let r)):
            return l == r
        case (.present(let l), .present(let r)):
            return l == r
        case (.pop(let l), .pop(let r)):
            return l == r
        case (.popToRoot, .popToRoot), (.dismiss, .dismiss):
            return true
        default:
            return false
        }
    }
}

/// This enumeration defines various presentations that a router can display in a navigation system.
public enum PresentMode: Identifiable, Sendable, Equatable {

    /// Represents a simple alert with a title and a message.
    case alert(title: String = "", message: String = "")

    /// Represents a confirmation dialog with a title and a list of action buttons.
    case confirmationDialog(title: String = "", actions: [AlertAction])

    /// Represents a sheet presentation that displays a view. It allows specifying detents for presentation size.
    case sheet(RouteView, detents: [PresentationDetents] = [.medium, .large])

    /// Represents a full-screen cover that displays a view over the entire screen.
    case fullScreenCover(RouteView)

    /// Represents a temporary toast notification with a message, style, and dismiss delay.
    case toast(message: String, style: ToastStyle, dismissDelay: Double = 3.0)

    /// Represents a loading indicator with a specific style.
    case loader(style: LoaderStyle = .default)

    /// Provides a unique string identifier for each case of the enum.
    public var id: String {
        switch self {
        case .alert(let title, let message):
            return "alert:\(title):\(message)"
        case .confirmationDialog(let title, let actions):
            let values = actions.map { "\($0.title):\($0.style.rawValue)" }.joined(separator: "|")
            return "confirmationDialog:\(title):\(values)"
        case .sheet:
            return "sheet:\(routeString ?? "nil")"
        case .fullScreenCover:
            return "fullScreenCover:\(routeString ?? "nil")"
        case .toast(let message, let style, let dismissDelay):
            return "toast:\(message):\(style):\(dismissDelay)"
        case .loader(let style):
            return "loader:\(style)"
        }
    }

    /// Returns a string representation of the route for certain cases. Returns nil for unrouteable cases.
    public var routeString: String? {
        switch self {
        case .toast, .alert, .confirmationDialog, .loader:
            return nil
        case .sheet(let view, let detents):
            return "sheet-\(view)-\(String(describing: detents))"
        case .fullScreenCover(let view):
            return "fullScreenCover-\(view)"
        }
    }

    /// Compares two PresentMode instances based on their unique identifiers.
    public static func == (lhs: PresentMode, rhs: PresentMode) -> Bool {
        switch (lhs, rhs) {
        case (.alert(let lt, let lm), .alert(let rt, let rm)):
            return lt == rt && lm == rm
        case (.confirmationDialog(let lt, let la), .confirmationDialog(let rt, let ra)):
            return lt == rt && la == ra
        case (.sheet, .sheet), (.fullScreenCover, .fullScreenCover):
            return lhs.routeString == rhs.routeString
        case (.toast(let lm, let ls, let ld), .toast(let rm, let rs, let rd)):
            return lm == rm && ls == rs && ld == rd
        case (.loader(let ls), .loader(let rs)):
            return ls == rs
        default:
            return false
        }
    }
}

public enum PresentationDetents: Sendable {
    /// The system detent for a sheet that's approximately half the height of
    /// the screen, and is inactive in compact height.
    case medium

    /// The system detent for a sheet at full height.
    case large

    /// A custom detent with the specified fractional height.
    case fraction(_ fraction: CGFloat)

    /// A custom detent with the specified height.
    case height(_ height: CGFloat)
}

/// Alert action for confirmation dialog
public struct AlertAction: Sendable {

    public enum Style: Int, Sendable {
        case `default` = 0
        case cancel = 1
        case destructive = 2
    }

    public let title: String
    public let style: Style
    public let handler: @MainActor @Sendable () -> Void

    public init(title: String, style: Style, handler: @escaping @MainActor @Sendable () -> Void) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

extension AlertAction: Equatable {
    public static func == (lhs: AlertAction, rhs: AlertAction) -> Bool {
        lhs.title == rhs.title && lhs.style == rhs.style
    }
}


#Preview {
    let router = NavigationKit.initialize()
    VStack(spacing: 20) {
        Button("info") {
            router.present(.toast(message: "Message \(Date())", style: .info))
        }
        Button("success") {
            router.present(.toast(message: "Message \(Date())", style: .success))
        }
        Button("warning") {
            router.present(.toast(message: "Message \(Date())", style: .warning))
        }
        Button("error") {
            router.present(.toast(message: "Message \(Date())", style: .error, dismissDelay: 0))
        }
        Button("loader") {
            router.present(.loader(style: .circle))
            Task {
                try await Task.sleep(nanoseconds: 3_000_000_000)
                router.dismiss()
            }
        }
    }
    .padding()
    .navigationKit()
}
