//
//  SwiftUINavigationModifier.swift
//
//
//  Created by Gerardo Grisolini on 08/12/23.
//

import SwiftUI

public struct SwiftUINavigationModifier: ViewModifier {
    public init() { }

    public func body(content: Content) -> some View {
        if #available(iOS 16.0, *), #available(macOS 13.0, *) {
            content.modifier(SwiftUINavigationV2Modifier())
        } else {
            content.modifier(SwiftUINavigationV1Modifier())
        }
    }
}

extension View {
    public func swiftUINavigation() -> some View {
        modifier(SwiftUINavigationModifier())
    }
}

@available(iOS 17.0, *)
@available(macOS 14.0, *)
#Preview {
    @Previewable let nav = FlowKit.registerNavigationSwiftUI(withFlowRouting: false)
    VStack(spacing: 20) {
        Button("Alert") {
            nav.present(.alert(title: "Warning", message: "Message"))
        }
        Button("ConfirmationDialog") {
            let actions: [AlertAction] = [
                .init(title: "Hide", style: .default, handler: {}),
                .init(title: "Delete logical", style: .cancel, handler: {}),
                .init(title: "Delete physical", style: .destructive, handler: {})
            ]
            nav.present(.confirmationDialog(title: "Confirmation", actions: actions))
        }
        Button("Sheet") {
            nav.present(.sheet(PresentableView()))
        }
#if os(iOS)
        Button("FullScreenCover") {
            nav.present(.fullScreenCover(PresentableView()))
        }
#endif
        Button("Navigate") {
            Task {
                await nav.navigate(view: Text("Navigate"))
            }
        }
    }
    .swiftUINavigation()
}

fileprivate struct PresentableView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("PresentableView")

            Button("Dismiss", role: .destructive) {
                dismiss()
            }
        }
    }
}
