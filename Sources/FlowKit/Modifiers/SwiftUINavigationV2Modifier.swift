//
//  SwiftUINavigationV2Modifier.swift
//  FlowCommon
//
//  Created by Gerardo Grisolini on 13/10/22.
//

import SwiftUI

@available(iOS 16.0, *)
@available(macOS 13.0, *)
public struct SwiftUINavigationV2Modifier: ViewModifier {
	@StateObject private var stack = FlowNavigationStackV2()

    public func body(content: Content) -> some View {
		NavigationStack(path: $stack.routes) {
			content
				.navigationDestination(for: String.self) { route in
                    Group {
                        if let view = stack.getView(route: route) {
                            AnyView(view)
                        } else {
                            EmptyView()
                        }
                    }
                    .navigationBarBackButtonHidden()
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button(action: stack.navigation.pop) {
                                Image(systemName: "chevron.backward")
                            }
                        }
                    }
				}
		}
        .overlay(alignment: .top) {
            if stack.isToast {
                AnyView(stack.presentedView)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.linear(duration: 0.5), value: stack.isToast)
        .alert(
            stack.title,
            isPresented: $stack.isAlert
        ) {
        } message: {
            AnyView(stack.presentedView)
        }
        .confirmationDialog(
            stack.title,
            isPresented: $stack.isConfirmationDialog,
            titleVisibility: stack.title.isEmpty ? .hidden : .visible
        ) {
            AnyView(stack.presentedView)
        }
        .sheet(isPresented: $stack.isSheet, onDismiss: stack.navigation.dismiss) {
            AnyView(stack.presentedView)
                .presentationDetents(stack.presentationDetents)
        }
#if os(iOS)
        .fullScreenCover(isPresented: $stack.isFullScreenCover, onDismiss: stack.navigation.dismiss) {
            AnyView(stack.presentedView)
        }
#endif
	}

    private func onDismiss() {
        stack.navigation.dismiss()
    }
}
