//
//  LoaderView.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 16/03/25.
//

import SwiftUI

public enum LoaderStyle: Sendable {
    case `default`
    case circle
}

struct LoaderView: View {
    @State private var degree: Int = 270
    @State private var spinnerLength = 0.6
    let style: LoaderStyle

    init(style: LoaderStyle) {
        self.style = style
    }

    var body: some View {
        ZStack {
            switch style {
            case .default:
                ProgressView().scaleEffect(3)

            case .circle:
                Circle()
                    .trim(from: 0.0, to: spinnerLength)
                    .stroke(LinearGradient(colors: [.red,.blue], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 8.0,lineCap: .round,lineJoin:.round))
                    .frame(width: 75, height: 75)
                    .animation(.easeIn(duration: 1.5).repeatForever(autoreverses: true), value: spinnerLength)
                    .rotationEffect(Angle(degrees: Double(degree)))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: degree)
                    .onAppear {
                        degree = 270 + 360
                        spinnerLength = 0
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.accentColor.opacity(0.2))
    }
}
