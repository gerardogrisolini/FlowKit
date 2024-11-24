//
//  NavigationItems.swift
//  
//
//  Created by Gerardo Grisolini on 04/03/24.
//

import Foundation

/// A collection of navigation items
public actor NavigationItems {

    private struct NavigationItem {
        let key: String
        var param: (any InOutProtocol)?
        var value: @Sendable (any InOutProtocol) async -> (any Sendable)
    }

    private var items = [NavigationItem]()

    var isEmpty: Bool {
        items.isEmpty
    }

    var count: Int {
        items.count
    }

    private func getIndex(for key: String) -> Int? {
        items.firstIndex(where: { $0.key == key })
    }

    func contains(_ key: String) -> Bool {
        items.contains(where: { $0.key == key })
    }

    func setValue(for key: String, value: @escaping @Sendable (any InOutProtocol) async -> (any Sendable)) {
        guard !contains(key) else { return }
        items.append(.init(key: key, value: value))
    }

    func setParam(for key: String, param: (any InOutProtocol)? = nil) -> Bool {
        guard let index = getIndex(for: key) else { return false }
        items[index].param = param
        return true
    }

    func getValue(for key: String) async -> (any Sendable)? {
        guard let index = getIndex(for: key) else { return nil }
        let item = items[index]
        return await item.value(item.param ?? InOutEmpty())
    }

    func remove(_ key: String) {
        guard let index = getIndex(for: key) else { return }
        items.remove(at: index)
    }
}
