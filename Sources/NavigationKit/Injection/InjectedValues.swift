//
//  InjectedValues.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 04/02/25.
//


/// Provides access to injected dependencies.
public struct InjectedValues {

    /// This is only used as an accessor to the computed properties within extensions of `InjectedValues`.
    nonisolated(unsafe) private static var current = InjectedValues()

    /// A static subscript for updating the `currentValue` of `InjectionKey` instances.
    public static subscript<K>(key: K.Type) -> K.Value where K : InjectionProvider {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    /// A static subscript accessor for updating and references dependencies directly.
    public static subscript<T>(_ keyPath: WritableKeyPath<InjectedValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}