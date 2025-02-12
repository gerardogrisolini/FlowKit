//
//  InOutProtocol+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

/// Extension for `InOutProtocol` providing unique identifiers and class name extraction.
public extension InOutProtocol {

    /// A unique identifier for the model.
    ///
    /// - Uses the `className` property to generate a string identifier.
    /// - This ensures each conforming type can be uniquely identified.
    var id: String { className }

    /// Extracts the class name of the conforming model.
    ///
    /// - Uses `String(describing: self).className` to retrieve a cleaned-up class name.
    /// - Relies on `className` from `String+Extension.swift` to remove unnecessary syntax.
    ///
    /// - Returns: A simplified, readable class name for the model.
    var className: String {
        String(describing: self).className
    }
}
