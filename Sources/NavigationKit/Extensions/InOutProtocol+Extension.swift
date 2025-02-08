//
//  InOutProtocol+Extension.swift
//  NavigationKit
//
//  Created by Gerardo Grisolini on 05/02/25.
//

public extension InOutProtocol {
    /// The id of the model
    var id: String { className }

    /// The className of the model
    var className: String {
        String(describing: self).className
    }
}
