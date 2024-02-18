//
//  NavigationAction.swift
//  FlowCommon
//
//  Created by Gerardo Grisolini on 12/10/22.
//

public enum NavigationAction: Equatable {
	case navigate(String)
	case present(String)
	case pop(String)
	case popToRoot
	case dismiss
}

