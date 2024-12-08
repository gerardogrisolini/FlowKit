//
//  UIKitModifier.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 30/11/24.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

public extension View {
    @ViewBuilder
    func uiKit(result: @escaping (UIView) -> ()) -> some View {
        self
            .background(UIKitHelper(result: result))
            .compositingGroup()
    }
}

fileprivate struct UIKitHelper: UIViewRepresentable {

    var result: (UIView) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            if let uiKitview = view.superview?.superview?.subviews.last?.subviews.first {
                result(uiKitview)
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {

    }
}
#endif
