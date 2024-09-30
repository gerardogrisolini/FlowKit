//
//  View+Extension.swift
//  
//
//  Created by Gerardo Grisolini on 27/02/24.
//

import SwiftUI

extension View where Self: FlowViewProtocol {
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
