//
//  Binding+Extension.swift
//  
//
//  Created by Gerardo Grisolini on 16/10/22.
//

import SwiftUI

public extension Binding where Value == Bool {
	init<Wrapped>(bindingOptional: Binding<Wrapped?>) {
		self.init(
			get: {
				bindingOptional.wrappedValue != nil
			},
			set: { newValue in
				guard newValue == false else { return }

				bindingOptional.wrappedValue = nil
			}
		)
	}
}

public extension Binding {
	func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
		return Binding<Bool>(bindingOptional: self)
	}
}
