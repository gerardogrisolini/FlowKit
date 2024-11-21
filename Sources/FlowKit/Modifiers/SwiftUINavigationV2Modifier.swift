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

    private var isAlert: Bool {
        guard let mode = stack.presentMode, case .alert(title: _, message: _) = mode else { return false }
        return true
    }
    private var isConfirmationDialog: Bool {
        guard let mode = stack.presentMode, case .confirmationDialog(title: _, actions: _) = mode else { return false }
        return true
    }
    private var isSheet: Bool {
        guard let mode = stack.presentMode, case .sheet(_, _) = mode else { return false }
        return true
    }
    private var isFullScreenCover: Bool {
        guard let mode = stack.presentMode, case .fullScreenCover(_) = mode else { return false }
        return true
    }

    private var title: String {
        switch stack.presentMode {
        case .alert(title: let title, _), .confirmationDialog(title: let title, _):
            return title
        default: return ""
        }
    }

    private var presentationDetents: Set<PresentationDetent> {
        switch stack.presentMode {
        case .sheet(_, detents: let detents):
            return Set(detents.map {
                switch $0 {
                case .medium:
                    return PresentationDetent.medium
                case .large:
                    return PresentationDetent.large
                case .fraction(let fraction):
                    return PresentationDetent.fraction(fraction)
                case .height(let height):
                    return PresentationDetent.height(height)
                }
            })
        default: return []
        }
    }

    private var presentedView: any View {
        switch stack.presentMode {
        case .sheet(let view, _), .fullScreenCover(let view):
            guard let view = view as? any View else {
                guard let vc = view as? UIViewController else {
                    return EmptyView()
                }
                return vc.toSwiftUI()
            }
            return view
        case .alert(title: _, message: let message):
            return Text(message)
        case .confirmationDialog(title: _, actions: let actions):
            return ForEach(actions, id: \.title) { action in
                Button(
                    action.title,
                    role: action.style == .destructive ? .destructive : nil
                ) {
                    action.handler()
                }
            }
        default:
            return EmptyView()
        }
    }

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
        .alert(
            title,
            isPresented: .constant(isAlert)
        ) {
        } message: {
            AnyView(presentedView)
        }
        .confirmationDialog(
            title,
            isPresented: .constant(isConfirmationDialog),
            titleVisibility: title.isEmpty ? .hidden : .visible
        ) {
            AnyView(presentedView)
        }
        .sheet(isPresented: .constant(isSheet), onDismiss: stack.navigation.dismiss) {
            AnyView(presentedView)
                .presentationDetents(presentationDetents)
        }
#if os(iOS)
        .fullScreenCover(isPresented: .constant(isFullScreenCover), onDismiss: stack.navigation.dismiss) {
            AnyView(presentedView)
        }
#endif
	}

    private func onDismiss() {
        stack.navigation.dismiss()
    }
}
