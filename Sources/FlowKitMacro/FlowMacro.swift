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

public struct FlowMacro: MemberMacro {
    public static func expansion<Declaration, Context>(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: Declaration,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: Context
    ) throws -> [SwiftSyntax.DeclSyntax] where Declaration: SwiftSyntax.DeclGroupSyntax, Context: SwiftSyntaxMacros.MacroExpansionContext {
        // Forward to the legacy overload to preserve existing behavior
        try expansion(of: node, providingMembersOf: declaration, in: context)
    }

    public static func expansion<Declaration, Context>(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {

            guard case .argumentList(let args) = node.arguments,
                  let firstArg = args.first,
                  let lastArg = args.last else {
                context.diagnose(
                    Diagnostic(node: node._syntaxNode, message: Diagnostics.invalidArguments)
                )
                return []
            }

            let expression = lastArg.expression.description
            let modifier = declaration.hasPublicModifier ? "public " : ""
            let route = "\(modifier)static let route = \(expression)"
            let model = firstArg.expression.description.dropLast(5)

            var routeModel = "InOutEmpty"
            if let index = expression.firstIndex(of: "(") {
                if let endIndex = expression.lastIndex(of: "(") {
                    let startIndex = expression.index(after: index)
                    routeModel = expression[startIndex..<endIndex].description}
            }

            var items: [SwiftSyntax.DeclSyntax] = [
                .init(stringLiteral: route),
                .init(stringLiteral: "\(modifier)typealias RouteModel = \(routeModel)"),
                .init(stringLiteral: "\(modifier)typealias Model = \(model)")
            ]

            guard let _ = declaration.memberBlock.members.compactMap({ $0.decl.as(InitializerDeclSyntax.self) }).first else {
                items.append(.init(stringLiteral: "\(modifier)init() { }"))
                return items
            }

            return items
        }
}

extension FlowMacro {
    enum Diagnostics: String, DiagnosticMessage {
        case invalidArguments

        var message: String {
            switch self {
            case .invalidArguments:
                return "`@Flow` requires at least model and route arguments."
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "FlowMacro", id: rawValue)
        }

        var severity: DiagnosticSeverity { .error }
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
