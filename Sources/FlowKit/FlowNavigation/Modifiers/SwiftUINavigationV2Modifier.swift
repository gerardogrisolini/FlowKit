//
//  SwiftUINavigationV2Modifier.swift
//  FlowCommon
//
//  Created by Gerardo Grisolini on 13/10/22.
//

import SwiftUI

@available(iOS 16.0, *)
public struct SwiftUINavigationV2Modifier: ViewModifier {
	
	@StateObject private var stack = FlowNavigationStackV2()

	public init() { }
	
	public func body(content: Content) -> some View {
		NavigationStack(path: $stack.routes) {
			content
				.navigationDestination(for: String.self) { route in
					stack.view(route: route)
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
		.sheet(isPresented: $stack.presentedView.mappedToBool(), onDismiss: stack.navigation.onDismiss) {
			AnyView(stack.presentedView!)
				.presentationDetents([.medium, .large])

		}
	}
}
