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
                        .start(model: model as! F.CoordinatorNode.View.In, navigate: false)
                } catch {
                    print("Error on joining flow: \(error)")
                }
            }
    }

    func preview() -> some View {
        self
            .task {
                do {
                    for try await event in events {
                        guard case .event(let e) = event, let e = e as? Event else { continue }
                        await onEventChanged(event: e, model: model)
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



