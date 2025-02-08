//
//  Task+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

import Combine

extension Task {
  func eraseToAnyCancellable() -> AnyCancellable {
        AnyCancellable(cancel)
    }
}
