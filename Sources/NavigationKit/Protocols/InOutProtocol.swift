//
//  InOutProtocol.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

/// **InOutProtocol: Input/Output Model Protocol**
///
/// This protocol serves as a **base contract for data models** used in `NavigationKit`.
/// It ensures that models used for input/output operations conform to **safe, structured, and identifiable data handling**.
///
/// - **Conforms to `Identifiable`**:
///   - Each model must have a unique identifier (`id`).
///   - This allows instances to be efficiently tracked and managed.
///
/// - **Conforms to `Sendable`**:
///   - This ensures the model is **safe to use in concurrent contexts**, such as Swift Concurrency (async/await).
///
/// ## Example Usage:
/// ```swift
/// struct UserModel: InOutProtocol {
///     let id: UUID
///     let name: String
/// }
/// ```
public protocol InOutProtocol: Identifiable, Sendable { }
