//
//  Nodable+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

/// Extension for `Nodable` to provide default behaviors for event identification,
/// data modeling, and associated value extraction.
public extension Nodable {

    /// The unique identifier for an event.
    ///
    /// - Uses `String(describing: self).className` to get the class name as a string.
    /// - Ensures each event type has a distinct identifier.
    var id: String {
        String(describing: self).className
    }

    /// The default data model associated with a view.
    ///
    /// - Returns `InOutEmpty.self` as a placeholder model.
    /// - Can be overridden in conforming types to provide a meaningful model.
    var model: InOutEmpty.Type { InOutEmpty.self }

    /// Extracts the first associated value of the event using reflection.
    ///
    /// - Uses Swift's `Mirror` API to inspect the properties of `self`.
    /// - If there is no associated value, it defaults to the event’s description and `nil`.
    /// - If an associated value exists, it attempts to cast it to `any InOutProtocol`.
    ///
    /// - Returns:
    ///   - `label`: The name of the associated property.
    ///   - `value`: The extracted value (if conforming to `InOutProtocol`), otherwise `nil`.
    var associated: (label: String, value: (any InOutProtocol)?) {
        let mirror = Mirror(reflecting: self)
        guard let associated = mirror.children.first else {
            return ("\(self)", nil) // Default fallback if no associated properties are found.
        }
        return (associated.label!, associated.value as? any InOutProtocol)
    }

    /// Provides a way to update the associated value of the event.
    ///
    /// - This function is likely intended to be overridden by conforming types.
    /// - The default implementation returns `self` without modifying anything.
    ///
    /// - Parameter associatedValue: A new associated value conforming to `InOutProtocol`.
    /// - Returns: The same instance (`self`) without any modifications.
    func udpate(associatedValue: some InOutProtocol) -> Self {
        self
    }
}
