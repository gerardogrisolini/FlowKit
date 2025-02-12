//
//  Injected.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 04/02/25.
//

/// **Injected Property Wrapper**
///
/// This property wrapper enables dependency injection by referencing values stored
/// in the `InjectedValues` container. It allows dependencies to be accessed using
/// key paths.
///
/// - Example Usage:
/// ```swift
/// @Injected(\.router) var router
/// ```
/// Here, `networkService` is injected based on the key path in `InjectedValues`.
@propertyWrapper
public struct Injected<T> {

    /// A writable key path to retrieve and set dependencies within `InjectedValues`.
    private let keyPath: WritableKeyPath<InjectedValues, T>

    /// The injected dependency accessed through the key path.
    ///
    /// - The `get` accessor fetches the value from `InjectedValues` using `keyPath`.
    /// - The `set` accessor allows modifying the value directly.
    public var wrappedValue: T {
        get { InjectedValues[keyPath] }
        set { InjectedValues[keyPath] = newValue }
    }

    /// Initializes the `Injected` wrapper with a specific key path.
    ///
    /// - Parameter keyPath: A `WritableKeyPath` that maps to a dependency in `InjectedValues`.
    public init(_ keyPath: WritableKeyPath<InjectedValues, T>) {
        self.keyPath = keyPath
    }
}
