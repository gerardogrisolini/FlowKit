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
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: Context
    ) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {
        guard case .argumentList(let args) = node.arguments else {
            context.diagnose(
                Diagnostic(node: node._syntaxNode, message: Diagnostics.invalidArguments)
            )
            return []
        }
        guard let first = args.first else {
            context.diagnose(
                Diagnostic(node: node._syntaxNode, message: Diagnostics.missingModelArgument)
            )
            return []
        }
        let model = first.expression.description.dropLast(5).description
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
"""
            if isClass {
                text += "\n    super.init(nibName: nil, bundle: nil)"
            }
            text += "}"

            decl.append(.init(stringLiteral: text))
        }

        return decl
    }
}

extension FlowViewMacro {
    enum Diagnostics: String, DiagnosticMessage {
        case invalidArguments
        case missingModelArgument

        var message: String {
            switch self {
            case .invalidArguments:
                return "`@FlowView` requires arguments."
            case .missingModelArgument:
                return "`@FlowView` requires a model type as first argument."
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "FlowViewMacro", id: rawValue)
        }

        var severity: DiagnosticSeverity { .error }
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
