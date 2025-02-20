//
//  NavigationV1Modifier.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 13/10/22.
//

import SwiftUI

@available(iOS 14.0, *)
@available(iOS, deprecated: 16.0)
@available(macOS, deprecated: 13.0)
public struct NavigationV1Modifier: ViewModifier {
    @StateObject var stack = RouterStackV1()
    @Namespace private var nameSpace

    public func body(content: Content) -> some View {
        NavigationView {
            content
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: stack.router.pop) {
                            Image(systemName: "chevron.backward")
                        }
                    }
                }
                .background(
                    NavigationLink(isActive: $stack.route.mappedToBool()) {
                        Group {
                            if let route = stack.route, let view = stack.getView(route: route) {
                                AnyView(view).modifier(NavigationV1Modifier())
                            }
                        }
                    } label: {
                        EmptyView()
                    }
                )
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
        .sheet(isPresented: $stack.isSheet) {
            AnyView(stack.presentedView)
        }
#if os(iOS)
        .fullScreenCover(isPresented: $stack.isFullScreenCover) {
            AnyView(stack.presentedView)
        }
#endif
    }
}
