//
//  EventStore.swift
//  
//
//  Created by Gerardo Grisolini on 04/03/24.
//

import Foundation

/// EventStore is the pages events store
actor EventStore {
    private var events = Dictionary<String, AsyncThrowingSubject<CoordinatorEvent>>()

    func get(key: String) -> AsyncThrowingSubject<CoordinatorEvent> {
        events[key] ?? append(key)
    }

    private func append(_ key: String) -> AsyncThrowingSubject<CoordinatorEvent> {
        let e = AsyncThrowingSubject<CoordinatorEvent>()
        events[key] = e
        return e
    }

    func remove(_ key: String) {
        events.removeValue(forKey: key)
    }
}
