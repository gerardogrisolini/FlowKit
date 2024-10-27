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
                    for try await event in await events {
                        guard case .event(let e) = event, let e = e as? Event else { continue }
                        await onEventChanged(event: e, model: model)
                    }
                } catch {
                    print(error)
                }
            }
            .onDisappear {
                Task { await events.finish() }
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


struct WidgetModifier<Parent: FlowViewProtocol>: ViewModifier {
    let events = AsyncThrowingSubject<CoordinatorEvent>()
    let parent: Parent

    init(parent: Parent) {
        self.parent = parent
    }

    func body(content: Content) -> some View {
        content
            .task {
                do {
                    for try await event in events {
//                        guard case .event(let e) = event, let e = e as? Event else { continue }
//                        await onEventChanged(event: e, model: model)
                        switch event {
                        case .event(let e):
                            guard let i = try parent.parse(e) as? Parent.Event else { continue }
                            parent.event(i)
                        case .next(let e):
                            guard let i = try parent.parse(e) as? Parent.Out else { continue }
                            parent.out(i)
                        case .navigate(let e):
                            parent.navigate(e)
                        case .back:
                            parent.back()
                        case .commit(let model, toRoot: let toRoot):
                            parent.commit(model, toRoot: toRoot)
                        case .present(let view):
                            parent.present(view)
                        }
                    }
                } catch {
                    print(error)
                }
            }
    }
}
