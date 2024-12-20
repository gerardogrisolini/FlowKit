//
//  Localizable.swift
//  
//
//  Created by Gerardo Grisolini on 02/04/23.
//

import SwiftUI

public protocol Localizable: Hashable, RawRepresentable where RawValue: StringProtocol {
	var localized: String { get }
	var injectedLocalized: String.LocalizationValue { get }
}

extension Localizable {
    public var injectedLocalized: String.LocalizationValue {
        let behavior = InjectedValues[\.flowBehavior]

        guard let injectedValue = behavior?.localizables.first(where: { $0.from as? Self == self }) else {
			return String.LocalizationValue(rawValue.description)
		}

        return String.LocalizationValue(injectedValue.to.rawValue as! String)
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
