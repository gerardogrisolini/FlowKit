//
//  Task+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

import Combine

/// Extension to provide a convenient method for converting a `Task`
/// into an `AnyCancellable`, allowing it to be stored in a `Set<AnyCancellable>`
/// for automatic cancellation.
extension Task {

  /// Converts the `Task` instance into an `AnyCancellable`,
  /// ensuring the task is canceled when the `AnyCancellable` is deallocated.
  ///
  /// - Returns: An `AnyCancellable` that cancels the `Task` when deinitialized.
  func eraseToAnyCancellable() -> AnyCancellable {
        AnyCancellable(cancel)
    }
}
