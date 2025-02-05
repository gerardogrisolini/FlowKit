//
//  Injected.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 04/02/25.
//


/// This allows us to reference dependencies using the key path accessor as shown
@propertyWrapper
public struct Injected<T> {
    private let keyPath: WritableKeyPath<InjectedValues, T>
    public var wrappedValue: T {
        get { InjectedValues[keyPath] }
        set { InjectedValues[keyPath] = newValue }
    }

    public init(_ keyPath: WritableKeyPath<InjectedValues, T>) {
        self.keyPath = keyPath
    }
}