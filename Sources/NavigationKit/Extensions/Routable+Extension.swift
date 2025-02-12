//
//  Routable+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

/// Extension for `Routable` providing helper properties to retrieve route-related information.
public extension Routable {

    /// Constructs a unique route string for navigation.
    ///
    /// - Uses the `associated.label` as an identifier for the route.
    /// - Appends the associated value's `className` or `"InOutEmpty"` if no value exists.
    var routeString: String {
        "\(associated.label) - \(associated.value?.className ?? "InOutEmpty")"
    }

    /// Extracts the first associated value from the conforming `Routable` type.
    ///
    /// - Uses Swift's `Mirror` API to inspect the properties of `self`.
    /// - If no associated value is found, defaults to `self` as a string with `nil` value.
    /// - Ensures the extracted value conforms to `InOutProtocol`.
    ///
    /// - Returns:
    ///   - `label`: The name of the associated property.
    ///   - `value`: The extracted value (if conforming to `InOutProtocol`), otherwise `nil`.
    var associated: (label: String, value: (any InOutProtocol)?) {
        let mirror = Mirror(reflecting: self)
        guard let associated = mirror.children.first else {
            return ("\(self)", nil) // Default to self as label with no value.
        }
        return (associated.label!, associated.value as? any InOutProtocol)
    }

    /// Defines the view associated with the route.
    ///
    /// - This property is meant to be overridden by conforming types to return an appropriate `RouteView`.
    /// - The default implementation returns `nil`, indicating no associated view by default.
    @MainActor var view: RouteView { nil }
}
