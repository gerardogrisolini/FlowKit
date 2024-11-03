//
//  FlowMacro.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 03/11/24.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum FlowMacro: MemberMacro {
    public static func expansion<Declaration, Context>(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {

        guard case .argumentList(let args) = node.arguments,
              let firstArg = args.first,
              let lastArg = args.last else {
            fatalError()
        }

        let modifier = declaration.hasPublicModifier ? "public " : ""
        let route = "\(modifier)static let route = \(lastArg.expression.description)"
        let model = firstArg.expression.description.dropLast(5)

        return [
            .init(stringLiteral: route),
            .init(stringLiteral: "\(modifier)typealias Model = \(model)"),
            .init(stringLiteral: "\(modifier)init() { }")
        ]
    }
}

private extension DeclGroupSyntax {
    var hasPublicModifier: Bool {
        modifiers.children(viewMode: .fixedUp)
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
        FlowMacro.self
    ]
}
