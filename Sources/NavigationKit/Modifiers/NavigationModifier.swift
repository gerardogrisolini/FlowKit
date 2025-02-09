//
//  NavigationModifier.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 08/12/23.
//

import SwiftUI

public struct NavigationModifier: ViewModifier {
    public init() { }

    public func body(content: Content) -> some View {
        if #available(iOS 16.0, *), #available(macOS 13.0, *) {
            content.modifier(NavigationV2Modifier())
        } else {
            content.modifier(NavigationV1Modifier())
        }
    }
}

@available(iOS 17.0, *)
@available(macOS 14.0, *)
#Preview {
    let router = NavigationKit.initialize()
    VStack(spacing: 20) {
        Button("Toast") {
            router.present(.toast(message: "Message \(Date())", style: .success))
        }
        Button("Alert") {
            router.present(.alert(title: "Warning", message: "Message"))
        }
        Button("ConfirmationDialog") {
            let actions: [AlertAction] = [
                .init(title: "Hide", style: .default, handler: {}),
                .init(title: "Delete logical", style: .cancel, handler: {}),
                .init(title: "Delete physical", style: .destructive, handler: {})
            ]
            router.present(.confirmationDialog(title: "Confirmation", actions: actions))
        }
        Button("Sheet") {
            router.present(.sheet(PresentableView()))
        }
#if os(iOS)
        Button("FullScreenCover") {
            router.present(.fullScreenCover(PresentableView()))
        }
#endif
        Button("Navigate") {
            router.navigate(view: Text("Navigate"))
        }
    }
    .navigationKit()
}

fileprivate struct PresentableView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Text("PresentableView")

            Button("Dismiss", role: .destructive) {
                dismiss()
            }
        }
    }
}
