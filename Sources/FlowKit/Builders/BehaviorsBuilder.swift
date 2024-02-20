//
//  BehaviorsBuilder.swift
//
//
//  Created by Gerardo Grisolini on 20/02/24.
//

import Foundation

public enum Behaviors {
    case localizable([any LocalizableJoinProtocol])
    case out([any OutJoinProtocol])
    case event([any EventJoinProtocol])
}

public func Localizables(@LocalizablesBuilder _ content: () -> [any LocalizableJoinProtocol]) -> Behaviors {
    .localizable(content())
}

public func Outs(@OutsBuilder _ content: () -> [any OutJoinProtocol]) -> Behaviors {
    .out(content())
}

public func Events(@EventsBuilder _ content: () -> [any EventJoinProtocol]) -> Behaviors {
    .event(content())
}

@resultBuilder
public enum BehaviorsBuilder {
    public static func buildBlock() -> [Behaviors] { [] }

    public static func buildBlock(_ components: (Behaviors)...) -> [Behaviors]  {
        components
    }

    public static func buildBlock(_ components: [Behaviors]...) -> [Behaviors]  {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[Behaviors]]) -> [Behaviors]  {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: Behaviors) -> [Behaviors] {
        [expression]
    }

    public static func buildOptional(_ components: [Behaviors]?) -> [Behaviors]  {
        components ?? []
    }

    public static func buildEither(first components: [Behaviors]) -> [Behaviors]  {
        components
    }

    public static func buildEither(second components: [Behaviors]) -> [Behaviors]  {
        components
    }

    public static func buildPartialBlock(first: [Behaviors]) -> [Behaviors] {
        first
    }

    public static func buildPartialBlock(accumulated: [Behaviors], next: [Behaviors]) -> [Behaviors] {
        accumulated + next
    }
}
