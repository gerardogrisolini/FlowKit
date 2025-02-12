//
//  Nodable.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

/// **Nodable Protocol**
///
/// This protocol defines the requirements for a type to be **"nodable"** in `NavigationKit`.
/// A **nodable** entity is identifiable and supports concurrency-safe interactions.
///
/// - Conforming types must:
///   - Be **identifiable** (`Identifiable` ensures a unique `id`).
///   - Be **concurrency-safe** (`Sendable` ensures safety when used across tasks).
///   - Define an **associated model** conforming to `InOutProtocol`.
///   - Provide a way to **update associated values dynamically**.
public protocol Nodable: Identifiable, Sendable {

    /// **Associated Data Model**
    ///
    /// - Each nodable entity must be linked to a **specific data model**.
    /// - The model must conform to `InOutProtocol`, ensuring structured data transfer.
    associatedtype Model: InOutProtocol

    /// **The Model Type**
    ///
    /// - Provides the type reference to the associated model.
    /// - This helps in dynamically determining the expected data format.
    var model: Model.Type { get }

    /// **Updates the associated value of the nodable entity.**
    ///
    /// - Allows modifying an existing nodable entity by providing a new associated value.
    /// - Returns an updated instance with the applied changes.
    ///
    /// - Parameter associatedValue: A new value conforming to `InOutProtocol`.
    /// - Returns: A modified instance of the conforming type.
    func udpate(associatedValue: some InOutProtocol) -> Self
}
