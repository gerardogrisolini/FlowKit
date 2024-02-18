//
//  UIKitPreviewWrapper.swift
//
//
//  Created by Gerardo Grisolini on 27/08/23.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

extension UIViewController {
	struct UIKitWrapper<T: UIViewController>: UIViewControllerRepresentable {
		let view: T
		public init(_ view: T) {
			self.view = view
		}
		public func makeUIViewController(context: Context) -> T { view }
		public func updateUIViewController(_ uiViewController: T, context: Context) { }
	}

	public func toSwiftUI() -> some UIViewControllerRepresentable {
		UIKitWrapper(self)
	}
}
#endif
