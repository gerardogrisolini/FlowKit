//
//  Binding+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 16/10/22.
//

import SwiftUI

/// Extension to provide convenience initializers and transformations for `Binding` objects.
public extension Binding where Value == Bool {

    /// Initializes a `Binding<Bool>` from an optional `Binding<Wrapped?>`.
    /// This allows checking whether the optional value is `nil` (false) or non-nil (true).
    ///
    /// - Parameter bindingOptional: A binding to an optional value.
    init<Wrapped: Sendable>(bindingOptional: Binding<Wrapped?>) {
        self.init(
            get: {
                // Returns `true` if the optional contains a value, `false` otherwise.
                bindingOptional.wrappedValue != nil
            },
            set: { newValue in
                // When `newValue` is `false`, set the optional to `nil`.
                // Prevents setting `true`, as the wrapped value cannot be inferred.
                guard newValue == false else { return }
                bindingOptional.wrappedValue = nil
            }
        )
    }
}

public extension Binding {

    /// Converts a `Binding<Wrapped?>` into a `Binding<Bool>`,
    /// where `true` indicates a non-nil value and `false` indicates `nil`.
    ///
    /// - Returns: A `Binding<Bool>` that represents the presence of a value.
    func mappedToBool<Wrapped: Sendable>() -> Binding<Bool> where Value == Wrapped? {
        return Binding<Bool>(bindingOptional: self)
    }
}
