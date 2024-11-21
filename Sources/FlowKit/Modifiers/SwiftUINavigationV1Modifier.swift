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
                Button(action.title) { action.handler() }
            }
        default:
            return EmptyView()
        }
    }

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
        .sheet(isPresented: .constant(isSheet)) {
            AnyView(presentedView)
        }
#if os(iOS)
        .fullScreenCover(isPresented: .constant(isFullScreenCover)) {
            AnyView(presentedView)
        }
#endif
    }
}
