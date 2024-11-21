//
//  NavigationItems.swift
//  
//
//  Created by Gerardo Grisolini on 04/03/24.
//

import Foundation

/// A collection of navigation items
@MainActor
public struct NavigationItems {
    private var items = Dictionary<String, () -> (any Sendable)>()

    var isEmpty: Bool {
        items.isEmpty
    }

    var count: Int {
        items.count
    }

    subscript(key: String) -> (() -> (any Sendable))? {
        get { items[key] }
        set { items[key] = newValue }
    }
    mutating func remove(_ key: String) {
        items.removeValue(forKey: key)
    }

    func contains(_ key: String) -> Bool {
        items.keys.contains(key)
    }
}
