//
//  SwiftUINavigationV1Modifier.swift
//  FlowCommon
//
//  Created by Gerardo Grisolini on 13/10/22.
//

import SwiftUI

@available(iOS 14.0, *)
@available(iOS, deprecated: 16.0)
@available(macOS, deprecated: 13.0)
public struct SwiftUINavigationV1Modifier: ViewModifier {
    @StateObject var stack = FlowNavigationStackV1()

    public func body(content: Content) -> some View {
        NavigationView {
            content
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: { Task { await stack.navigation.pop() }}) {
                            Image(systemName: "chevron.backward")
                        }
                    }
                }
                .background(
                    NavigationLink(isActive: $stack.route.mappedToBool()) {
                        Group {
                            if let view = stack.view {
                                AnyView(view).modifier(SwiftUINavigationV1Modifier())
                            } else {
                                EmptyView()
                            }
                        }
                        .onAppear {
                            if let route = stack.route {
                                Task { await stack.setView(route: route) }
                            }
                        }
                    } label: {
                        EmptyView()
                    }
                )
        }
//        .navigationBarHidden(true)
        .alert(
            stack.title,
            isPresented: .constant(stack.isAlert)
        ) {
        } message: {
            AnyView(stack.presentedView)
        }
        .confirmationDialog(
            stack.title,
            isPresented: .constant(stack.isConfirmationDialog),
            titleVisibility: stack.title.isEmpty ? .hidden : .visible
        ) {
            AnyView(stack.presentedView)
        }
        .sheet(isPresented: .constant(stack.isSheet)) {
            AnyView(stack.presentedView)
        }
#if os(iOS)
        .fullScreenCover(isPresented: .constant(stack.isFullScreenCover)) {
            AnyView(stack.presentedView)
        }
#endif
    }
}
