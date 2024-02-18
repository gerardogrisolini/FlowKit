//
//  Localizable.swift
//  
//
//  Created by Gerardo Grisolini on 02/04/23.
//

import SwiftUI
import Resolver

public protocol Localizable: Hashable, RawRepresentable where RawValue: StringProtocol {
	var localized: String { get }
	var injectedLocalized: String.LocalizationValue { get }
}

extension Localizable {
    public var injectedLocalized: String.LocalizationValue {
        @OptionalInjected var flow: FlowBehaviorProtocol?

        guard let injectedValue = flow?.behavior.keys[self] else {
			return String.LocalizationValue(rawValue.description)
		}

		return String.LocalizationValue(injectedValue)
	}

//    public var localized: String {
//        print(Bundle.module.bundlePath)
//        return String(localized: injectedLocalized, bundle: .module)
//    }
}

extension String {
	public var firstLetterCapitalized: String {
		let firstLetter = prefix(1).capitalized
		let remainingLetters = dropFirst()
		return firstLetter + remainingLetters
	}
}
