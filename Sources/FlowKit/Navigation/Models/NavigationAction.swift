//
//  NavigationAction.swift
//
//
//  Created by Gerardo Grisolini on 12/10/22.
//

/// NavigationAction is the enum that contains the navigation actions
public enum NavigationAction: Equatable {
	case navigate(String)
	case present(String)
	case pop(String)
	case popToRoot
	case dismiss
}

