//
//  View+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

import SwiftUI

/// Extension to enhance SwiftUI `View` with navigation-related functionality.
public extension View {

    /// The route string for the navigable view.
    ///
    /// - Generates a unique identifier for the view based on its type.
    /// - Helps with navigation and route management in `NavigationKit`.
    var routeString: String {
        String(describing: type(of: self))
    }

    /// Applies a navigation modifier to the view.
    ///
    /// - This method applies `NavigationModifier()`, which likely manages
    ///   routing behavior or navigation state within `NavigationKit`.
    /// - Enables streamlined navigation handling for SwiftUI views.
    ///
    /// - Returns: A modified SwiftUI `View` with navigation capabilities.
    func navigationKit() -> some View {
        modifier(NavigationModifier())
    }

    #if !os(macOS)
    /// Converts the SwiftUI view into a `UIHostingController`.
    ///
    /// - Uses `UIHostingController` to embed SwiftUI views inside UIKit.
    /// - This allows seamless integration of SwiftUI within UIKit-based apps.
    ///
    /// - Returns: A `UIHostingController<AnyView>` wrapping the current SwiftUI view.
    @MainActor func toUIKit() -> UIHostingController<AnyView> {
        UIHostingController(rootView: AnyView(self))
    }
    #endif
}
