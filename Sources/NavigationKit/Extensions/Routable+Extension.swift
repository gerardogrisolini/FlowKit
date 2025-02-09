//
//  Routable+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

public extension Routable {

    /// The route string for the navigable
    var routeString: String {
        "\(associated.label) - \(associated.value?.className ?? "InOutEmpty")"
    }

    /// Associated value of the route
    var associated: (label: String, value: (any InOutProtocol)?) {
        let mirror = Mirror(reflecting: self)
        guard let associated = mirror.children.first else {
            return ("\(self)", nil)
        }
        return (associated.label!, associated.value as? any InOutProtocol)
    }

    /// Associated view of the route
    @MainActor var view: (any Sendable)? { nil }
}
