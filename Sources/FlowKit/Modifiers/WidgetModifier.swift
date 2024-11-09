//
//  WidgetModifier.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 09/11/24.
//

import SwiftUI

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
