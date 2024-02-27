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
                        print(event)
                        guard case .event(let e) = event, let e = e as? Event else { continue }
                        onEventChanged(e, nil)
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
