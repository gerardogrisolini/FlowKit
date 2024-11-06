//
//  FlowViewMacro.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 03/11/24.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct FlowViewMacro: MemberMacro {
    public static func expansion<Declaration, Context>(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {
        guard case .argumentList(let args) = node.arguments else {
            fatalError()
        }
        let model = args.first?.expression.description.dropLast(5).description ?? ""
        let initializer = args.count == 2 ? args.last?.expression.description == "true" : true

        let modifier = declaration.hasPublicModifier ? "public " : ""
        let events = "\(modifier)let events = AsyncThrowingSubject<CoordinatorEvent>()"
        var decl: [DeclSyntax] = [
            .init(stringLiteral: events),
            .init(stringLiteral: "\(modifier)let model: \(model)")
        ]

        if initializer {
            let isClass = declaration is ClassDeclSyntax
            var text = """
\(modifier)\(isClass ? "required " : "")init(model: \(model) = \(model)()) {
    self.model = model
}
"""
            if isClass {
                text += "super.init(nibName: nil, bundle: nil)"
            }
            decl.append(.init(stringLiteral: text))
        }

        return decl
    }
}

private extension DeclGroupSyntax {
    var hasPublicModifier: Bool {
        self.modifiers.children(viewMode: .fixedUp)
            .compactMap { syntax in
                syntax.as(DeclModifierSyntax.self)?
                    .children(viewMode: .fixedUp)
                    .contains { syntax in
                        switch syntax.as(TokenSyntax.self)?.tokenKind {
                        case .keyword(.public):
                            return true
                        default:
                            return false
                        }
                    }
            }
            .contains(true)
    }
}

@main
struct MacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FlowViewMacro.self
    ]
}
