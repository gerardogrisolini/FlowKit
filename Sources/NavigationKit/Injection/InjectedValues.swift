//
//  InjectedValues.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 04/02/25.
//

/// **InjectedValues: Dependency Injection Container**
///
/// This struct serves as a **global dependency injection container** for managing dependencies.
/// It allows storing and accessing dependencies dynamically using **key paths** and **subscripts**.
///
/// - Dependencies are injected via `InjectionProvider`, making it easy to override values at runtime.
/// - Used alongside `Injected<T>` property wrapper for simplified access to dependencies.
///
/// ## Example Usage:
/// ```swift
/// extension InjectedValues {
///     var networkService: NetworkServiceProtocol {
///         get { Self[NetworkServiceProvider.self] }
///         set { Self[NetworkServiceProvider.self] = newValue }
///     }
/// }
///
/// @Injected(\.networkService) var networkService
/// ```
public struct InjectedValues {

    /// **Singleton-like Instance**
    ///
    /// - Stores the current instance of `InjectedValues` for global access.
    /// - Main-actor isolated to keep reads/writes concurrency-safe.
    @MainActor private static var current = InjectedValues()

    /// **Injection Provider-based Dependency Access**
    ///
    /// - Provides a **static subscript** that allows retrieving and updating dependencies
    ///   based on an `InjectionProvider` implementation.
    /// - Enables defining **custom keys** for dependency injection using types conforming to `InjectionProvider`.
    ///
    /// ## Example:
    /// ```swift
    /// protocol InjectionProvider {
    ///     associatedtype Value
    ///     static var currentValue: Value { get set }
    /// }
    ///
    /// struct NetworkServiceProvider: InjectionProvider {
    ///     static var currentValue: NetworkServiceProtocol = DefaultNetworkService()
    /// }
    /// ```
    @MainActor public static subscript<K>(key: K.Type) -> K.Value where K: InjectionProvider {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    /// **KeyPath-based Dependency Injection**
    ///
    /// - Provides a **static subscript** that allows accessing dependencies **directly**
    ///   via `WritableKeyPath<InjectedValues, T>`.
    /// - This allows updating dependencies in a **more structured way**, avoiding `InjectionProvider` if not needed.
    ///
    /// ## Example:
    /// ```swift
    /// extension InjectedValues {
    ///     var networkService: NetworkServiceProtocol {
    ///         get { Self[NetworkServiceProvider.self] }
    ///         set { Self[NetworkServiceProvider.self] = newValue }
    ///     }
    /// }
    /// ```
    @MainActor public static subscript<T>(_ keyPath: WritableKeyPath<InjectedValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}
