//
//  View+Extension.swift
//  
//
//  Created by Gerardo Grisolini on 27/02/24.
//

import SwiftUI

public extension View where Self: FlowViewProtocol {
    /// Join a view with the flow
    /// - Parameters:
    /// - flow: the flow to join
    /// - Returns: the view
    func join<F: FlowProtocol>(flow: F) -> some View {
        swiftUINavigation()
            .task {
                do {
                    try await Coordinator(flow: flow, parent: self)
                        .start(navigate: false)
                } catch {
                    print("Error on joining flow: \(error)")
                }
            }
    }

    /// To enable events and navigation management in preview
    func preview() -> some View {
        self
            .task {
                do {
                    //let nav = NavigationSwiftUI()
                    let nav: NavigationProtocol = Resolver.resolve()
                    for try await event in events {
                        print(event)
                        switch event {
                        case .event(let e):
                            guard let e = e as? Event else { continue }
                            await onEventChanged(event: e, model: model)
                        case .navigate(let view):
                            await nav.navigate(view: view)
                        case .present(let mode):
                            nav.present(mode)
                        default:
                            continue
                        }
                    }
                } catch {
                    print(error)
                }
            }
            .onDisappear {
                events.finish()
            }
    }
}

public extension View where Self: FlowWidgetProtocol {
    func widget(on parent: any FlowViewProtocol) -> some View {
        self.environment(\.parent, parent)
    }

    func test(parent: any FlowViewProtocol) throws {
        for e in Out.allCases {
            _ = try parent.parse(e)
        }
        for e in Event.allCases {
            _ = try parent.parse(e)
        }
    }
}

#if canImport(UIKit)
public extension View {
    func toUIKit() -> UIView {
        UIHostingController(rootView: self).view!
    }
}
#endif
