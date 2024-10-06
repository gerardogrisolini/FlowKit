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

    public func preview() -> some View {
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
    public func widget(on parent: any FlowViewProtocol) -> some View {
        self.environment(\.parent, parent)
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
                        case .next(let e, _):
                            guard let i = try parent.parse(e) as? Parent.Out else { continue }
                            parent.out(i)
                        case .navigate(let e):
                            await parent.navigate(e)
                        case .back:
                            await parent.back()
                        case .commit(let model, toRoot: let toRoot):
                            await parent.commit(model, toRoot: toRoot)
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
