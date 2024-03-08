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
        if #available(iOS 16.0, *) {
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
