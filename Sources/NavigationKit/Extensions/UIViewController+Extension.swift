//
//  UIViewController+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 27/08/23.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

extension UIViewController {

    /// The route string for the navigable
    var routeString: String {
        String(describing: type(of: self))
    }

    /// UIViewController wrapper
    struct UIViewControllerWrapper<T: UIViewController>: UIViewControllerRepresentable {
        let view: T
        public init(_ view: T) {
            self.view = view
        }
        public func makeUIViewController(context: Context) -> T { view }
        public func updateUIViewController(_ uiViewController: T, context: Context) { }
    }

    /// UIViewController to UIViewControllerRepresentable
    public func toSwiftUI() -> some UIViewControllerRepresentable {
        UIViewControllerWrapper(self)
    }
}

extension UIView {

    /// UIView wrapper
    struct UIViewWrapper<T: UIView>: UIViewRepresentable {
        let view: T
        public init(_ view: T) {
            self.view = view
        }
        public func makeUIView(context: Context) -> T { view }
        public func updateUIView(_ uiView: T, context: Context) { }
    }

    /// UIView to UIViewRepresentable
    public func toSwiftUI() -> some UIViewRepresentable {
        UIViewWrapper(self)
    }
}
#endif
