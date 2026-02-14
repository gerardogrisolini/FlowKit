//
//  UIViewController+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 27/08/23.
//

#if canImport(UIKit) && !os(visionOS)
import SwiftUI
import UIKit

/// Extension to provide SwiftUI compatibility for `UIViewController` and `UIView`.
extension UIViewController {

    /// Generates a unique route string for the current view controller.
    ///
    /// - Uses `String(describing: type(of: self))` to extract the class name of the `UIViewController`.
    /// - This helps identify view controllers uniquely when used in a navigation system.
    var routeString: String {
        String(describing: type(of: self))
    }

    /// A wrapper struct that allows a `UIViewController` to be used in SwiftUI.
    ///
    /// - `UIViewControllerRepresentable` is used to bridge UIKit's `UIViewController` with SwiftUI.
    /// - This wrapper enables embedding UIKit-based view controllers within a SwiftUI hierarchy.
    struct UIViewControllerWrapper<T: UIViewController>: UIViewControllerRepresentable {
        let view: T

        /// Initializes the wrapper with a specific `UIViewController`.
        ///
        /// - Parameter view: The `UIViewController` instance to be wrapped.
        public init(_ view: T) {
            self.view = view
        }

        /// Creates the `UIViewController` instance for SwiftUI.
        ///
        /// - Returns: The wrapped `UIViewController` instance.
        public func makeUIViewController(context: Context) -> T { view }

        /// Updates the `UIViewController` when SwiftUI requires it.
        ///
        /// - Note: Since `UIViewController` is stateful, this method is often empty.
        public func updateUIViewController(_ uiViewController: T, context: Context) { }
    }

    /// Converts a `UIViewController` to a SwiftUI-compatible representation.
    ///
    /// - Returns: A `UIViewControllerRepresentable` that allows the `UIViewController` to be used in SwiftUI.
    public func toSwiftUI() -> some UIViewControllerRepresentable {
        UIViewControllerWrapper(self)
    }
}

extension UIView {

    /// A wrapper struct that allows a `UIView` to be used in SwiftUI.
    ///
    /// - Similar to `UIViewControllerWrapper`, but for `UIView`.
    /// - Enables embedding UIKit views within SwiftUI components.
    struct UIViewWrapper<T: UIView>: UIViewRepresentable {
        let view: T

        /// Initializes the wrapper with a specific `UIView`.
        ///
        /// - Parameter view: The `UIView` instance to be wrapped.
        public init(_ view: T) {
            self.view = view
        }

        /// Creates the `UIView` instance for SwiftUI.
        ///
        /// - Returns: The wrapped `UIView` instance.
        public func makeUIView(context: Context) -> T { view }

        /// Updates the `UIView` when SwiftUI requires it.
        ///
        /// - Note: Since `UIView` is stateful, this method is often empty.
        public func updateUIView(_ uiView: T, context: Context) { }
    }

    /// Converts a `UIView` to a SwiftUI-compatible representation.
    ///
    /// - Returns: A `UIViewRepresentable` that allows the `UIView` to be used in SwiftUI.
    public func toSwiftUI() -> some UIViewRepresentable {
        UIViewWrapper(self)
    }
}
#endif
