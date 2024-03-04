//
//  SwiftUINavigationV1Modifier.swift
//  FlowCommon
//
//  Created by Gerardo Grisolini on 13/10/22.
//

import SwiftUI

@available(iOS 14.0, *)
public struct SwiftUINavigationV1Modifier: ViewModifier {
    
    @StateObject var stack = FlowNavigationStackV1()

    public init() { }
    
    public func body(content: Content) -> some View {
        NavigationView {
            content
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: stack.navigation.pop) {
                            Image(systemName: "chevron.backward")
                        }
                    }
                }
                .background(
                    NavigationLink(isActive: $stack.route.mappedToBool()) {
                        if let view = stack.view {
                            view.modifier(SwiftUINavigationV1Modifier())
                        } else {
                            EmptyView()
                        }
                    } label: {
                        EmptyView()
                    }
                )
        }
//        .navigationBarHidden(true)
		.sheet(isPresented: $stack.presentedView.mappedToBool()) {
            AnyView(stack.presentedView!)
        }
    }
}

