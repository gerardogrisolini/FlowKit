//
//  UIKitNavigationModifier.swift
//  
//
//  Created by Gerardo Grisolini on 04/05/23.
//

import SwiftUI
import Resolver

public struct UIKitNavigationModifier: ViewModifier {
    @Injected var navigation: NavigationProtocol

    public init() { }
    
    public func body(content: Content) -> some View {
        NavigationView {
            content
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: navigation.pop) {
                            Image(systemName: navigation.routes.isEmpty ? "" : "chevron.backward")
                        }
                    }
                }
        }
    }
}

