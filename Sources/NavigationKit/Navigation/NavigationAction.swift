//
//  NavigationAction.swift
//
//
//  Created by Gerardo Grisolini on 12/10/22.
//

import SwiftUI
import Combine

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

    public var routeString: String? {
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

/// Toast view
struct ToastView: View {
    private var cancellables: Set<AnyCancellable> = []

    let style: ToastStyle
    let message: String
    let onCancelTapped: (() -> Void)

    init(style: ToastStyle, message: String, dismissDelay: Double = 3.0, onCancelTapped: @escaping () -> Void) {
        self.style = style
        self.message = message
        self.onCancelTapped = onCancelTapped

        guard dismissDelay > 0 else { return }

        Task {
            try await Task.sleep(nanoseconds: UInt64(dismissDelay * 1_000_000_000))
            onCancelTapped()
        }
        .eraseToAnyCancellable()
        .store(in: &cancellables)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: style.iconFileName)
                .foregroundColor(style.themeColor)

            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)

            Spacer(minLength: 10)

            Button {
                onCancelTapped()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(style.themeColor)
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(style.themeColor.opacity(0.3))
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}

public enum ToastStyle: Sendable {
    case error
    case warning
    case success
    case info

    var themeColor: Color {
        switch self {
            case .error: return Color.red
            case .warning: return Color.orange
            case .info: return Color.blue
            case .success: return Color.green
        }
    }

    var iconFileName: String {
        switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
        }
    }
}

#Preview {
    let nav = NavigationKit.initialize()
    VStack(spacing: 20) {
        Button("info") {
            nav.present(.toast(message: "Message \(Date())", style: .info))
        }
        Button("success") {
            nav.present(.toast(message: "Message \(Date())", style: .success))
        }
        Button("warning") {
            nav.present(.toast(message: "Message \(Date())", style: .warning))
        }
        Button("error") {
            nav.present(.toast(message: "Message \(Date())", style: .error, dismissDelay: 0))
        }
    }
    .navigationKit()
}
