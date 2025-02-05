//
//  Nodable+Extension.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

public extension Nodable {
    /// The id of the event
    var id: String {
        String(describing: self).className
    }

    /// Default model for view
    var model: InOutEmpty.Type { InOutEmpty.self }

    /// Associated value of the event
    var associated: (label: String, value: (any InOutProtocol)?) {
        let mirror = Mirror(reflecting: self)
        guard let associated = mirror.children.first else {
            return ("\(self)", nil)
        }
        return (associated.label!, associated.value as? any InOutProtocol)
    }

    func udpate(associatedValue: some InOutProtocol) -> Self {
        self
    }
}
