//
//  String+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

/// Extension for `String` providing helper properties to extract class names and identifiers.
public extension String {

    /// Extracts an identifier from a fully qualified class name.
    ///
    /// - If the string contains a period (`.`), it assumes a namespaced class name (e.g., `Module.ClassName`).
    /// - Extracts only the portion **after** the last period (`.`) to isolate the class name.
    /// - Converts the extracted portion using the `className` property.
    ///
    /// - Returns: A simplified class name identifier.
    var id: String {
        var data = self
        if let start = self.lastIndex(of: ".") {
            // Find the index after the last period (".") to extract the class name.
            let index = data.index(start, offsetBy: 1)
            data = String(data.suffix(from: index))
        }
        return data.className
    }

    /// Extracts a class name from a string representation, removing any function-like syntax.
    ///
    /// - If the string contains `(` (indicating a function or generic type), it removes everything from that point onward.
    /// - If no `(` is found, it returns the string as is.
    ///
    /// - Returns: A cleaned-up class name without function-related characters.
    var className: String {
        guard let index = firstIndex(of: "(") else {
            return self // No function syntax detected, return the string unchanged.
        }
        let end = self.index(index, offsetBy: -1)
        return String(prefix(through: end)) // Extract everything before "(".
    }
}
