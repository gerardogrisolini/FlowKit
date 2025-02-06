//
//  View+Extension.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

import SwiftUI

public extension View {

    /// The route string for the navigable
    var routeString: String {
        String(describing: type(of: self))
    }

    /// SwiftUI navigation
    func navigationKit() -> some View {
        modifier(SwiftUINavigationModifier())
    }
}
