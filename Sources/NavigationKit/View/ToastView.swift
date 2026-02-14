//
//  ToastView.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 16/03/25.
//

import SwiftUI
import Combine

public enum ToastStyle: Sendable, Equatable {
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
