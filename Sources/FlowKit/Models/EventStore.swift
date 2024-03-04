//
//  EventStore.swift
//  
//
//  Created by Gerardo Grisolini on 04/03/24.
//

import Foundation

/// EventStore is the pages events store
struct EventStore {
    private var events = Dictionary<String, AsyncThrowingSubject<CoordinatorEvent>>()
    subscript(key: String) -> AsyncThrowingSubject<CoordinatorEvent>? {
        get { events[key] }
        set { events[key] = newValue }
    }
    mutating func remove(_ key: String) {
        events.removeValue(forKey: key)
    }
}
