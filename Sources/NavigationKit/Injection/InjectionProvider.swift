//
//  InjectionProvider.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 04/02/25.
//


public protocol InjectionProvider {

    /// The associated type representing the type of the dependency injection key's value.
    associatedtype Value

    /// The default value for the dependency injection key.
    static var currentValue: Self.Value { get set }
}
