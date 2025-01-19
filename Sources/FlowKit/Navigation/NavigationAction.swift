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
    case toast(message: String, style: ToastStyle)

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

/// Default toast view
public enum ToastStyle: Sendable {
    case error
    case warning
    case success
    case info
}

extension ToastStyle {
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

struct ToastView: View {
    var style: ToastStyle
    var message: String
    var width = CGFloat.infinity
    var onCancelTapped: (() -> Void)

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
        .frame(minWidth: 0, maxWidth: width)
        .background(style.themeColor.opacity(0.3))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onCancelTapped()
            }
        }
    }
}

#Preview {
    ToastView(style: .info, message: "Hello World", onCancelTapped: {})
    ToastView(style: .success, message: "Hello World", onCancelTapped: {})
    ToastView(style: .warning, message: "Hello World", onCancelTapped: {})
    ToastView(style: .error, message: "Hello World", onCancelTapped: {})
}
