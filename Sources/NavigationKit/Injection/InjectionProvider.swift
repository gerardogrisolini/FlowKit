//
//  InjectionProvider.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 04/02/25.
//

/// **InjectionProvider Protocol**
///
/// This protocol defines a generic interface for managing dependency injection keys.
///
/// - It allows defining a **static dependency container** for any type.
/// - Each dependency must conform to `InjectionProvider` and provide a `currentValue`.
/// - This enables **dynamic dependency swapping**, making it useful for dependency injection frameworks.
///
/// ## Example Usage:
/// ```swift
/// struct NetworkServiceProvider: InjectionProvider {
///     static var currentValue: NetworkServiceProtocol = DefaultNetworkService()
/// }
///
/// extension InjectedValues {
///     var networkService: NetworkServiceProtocol {
///         get { Self[NetworkServiceProvider.self] }
///         set { Self[NetworkServiceProvider.self] = newValue }
///     }
/// }
///
/// @Injected(\.networkService) var networkService
/// ```
public protocol InjectionProvider {

    /// **The associated type representing the dependency's value.**
    ///
    /// - Each dependency must define a concrete `Value` type.
    /// - Example: A `LoggerServiceKey` would have `Value` as `LoggerProtocol`.
    associatedtype Value

    /// **Holds the current instance of the dependency.**
    ///
    /// - This is the actual dependency being injected.
    /// - It can be overridden at runtime to provide mock implementations (useful for testing).
    /// - Stored as a `static var`, allowing global access.
    static var currentValue: Self.Value { get set }
}
