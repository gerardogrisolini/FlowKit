//
//  NavigationItems.swift
//
//
//  Created by Gerardo Grisolini on 04/03/24.
//

import Foundation

/// A collection of navigation items designed to manage navigation state in an asynchronous and thread-safe manner.
public class NavigationItems {

    /// Represents a single navigation item with an associated key, optional parameter, and a value provider.
    private struct NavigationItem {
        /// A unique identifier for the navigation item.
        let key: String

        /// An optional parameter conforming to `InOutProtocol` used when retrieving the value.
        var param: (any InOutProtocol)?

        /// A closure that provides a value asynchronously, taking an `InOutProtocol` as input and returning a `Sendable` result.
        var value: @MainActor @Sendable (any InOutProtocol) -> (any Sendable)
    }

    /// An array holding all navigation items.
    private var items = [NavigationItem]()

    /// A computed property indicating whether the collection of navigation items is empty.
    var isEmpty: Bool {
        items.isEmpty
    }

    /// A computed property returning the total number of navigation items.
    var count: Int {
        items.count
    }

    /// Retrieves the index of a navigation item with the given key.
    /// - Parameter key: The unique identifier for the navigation item.
    /// - Returns: The index of the navigation item if found; otherwise, `nil`.
    private func getIndex(for key: String) -> Int? {
        items.firstIndex(where: { $0.key == key })
    }

    /// Checks whether a navigation item with the specified key exists in the collection.
    /// - Parameter key: The unique identifier to search for.
    /// - Returns: `true` if the item exists; otherwise, `false`.
    func contains(_ key: String) -> Bool {
        items.contains(where: { $0.key == key })
    }

    /// Adds a new navigation item with the specified key and value provider.
    /// - Parameters:
    ///   - key: The unique identifier for the new item.
    ///   - value: A closure providing the asynchronous value for the item.
    /// - Note: This function does nothing if an item with the same key already exists.
    func setValue(for key: String, value: @escaping @MainActor @Sendable (any InOutProtocol) -> (any Sendable)) {
        guard !contains(key) else { return }
        items.append(.init(key: key, value: value))
    }

    /// Retrieves the value of a navigation item asynchronously.
    /// - Parameter key: The unique identifier for the navigation item.
    /// - Returns: The asynchronously computed value of the item, or `nil` if the item is not found.
    @MainActor func getValue(for key: String) -> (any Sendable)? {
        guard let index = getIndex(for: key) else { return nil }
        let item = items[index]
        return item.value(item.param ?? InOutEmpty())
    }

    /// Sets the parameter for a navigation item.
    /// - Parameters:
    ///   - key: The unique identifier for the navigation item.
    ///   - param: An optional parameter conforming to `InOutProtocol` to associate with the item.
    /// - Returns: `true` if the parameter was set successfully; otherwise, `false`.
    func setParam(for key: String, param: (any InOutProtocol)? = nil) -> Bool {
        guard let index = getIndex(for: key) else { return false }
        items[index].param = param
        return true
    }

    /// Retrieves the parameter associated with a navigation item.
    /// - Parameter key: The unique identifier for the navigation item.
    /// - Returns: The parameter associated with the item, or `nil` if the item is not found.
    func getParam(for key: String) -> (any InOutProtocol)? {
        guard let index = getIndex(for: key) else { return nil }
        return items[index].param
    }

    /// Removes a navigation item from the collection.
    /// - Parameter key: The unique identifier for the navigation item to be removed.
    func remove(_ key: String) {
        guard let index = getIndex(for: key) else { return }
        items.remove(at: index)
    }
}
