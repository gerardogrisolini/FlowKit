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
        in context: Context) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {

        guard case .argumentList(let args) = node.arguments,
              let firstArg = args.first,
              let lastArg = args.last else {
            fatalError()
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

//        let members = declaration.memberBlock.members
//        let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
//        let variablesName = variableDecl.compactMap { $0.bindings.first?.pattern }
//        let variablesType = variableDecl.compactMap { $0.bindings.first?.typeAnnotation?.type }
//        let initializer = try InitializerDeclSyntax(generateInitialCode(
//            modifier: modifier,
//            variablesName: variablesName,
//            variablesType:variablesType
//        )) {
//            for name in variablesName {
//                ExprSyntax("self.\(name) = \(name)")
//            }
//        }
//        items.append(.init(initializer))

        guard let _ = declaration.memberBlock.members.compactMap({ $0.decl.as(InitializerDeclSyntax.self) }).first else {
            items.append(.init(stringLiteral: "\(modifier)init() { }"))
            return items
        }

        return items
    }

//    static func generateInitialCode(modifier: String,
//                             variablesName: [PatternSyntax],
//                             variablesType: [TypeSyntax]) -> PartialSyntaxNodeString {
//        var initialCode: String = "\(modifier)init("
//        for (name, type) in zip(variablesName, variablesType) {
//            initialCode += "\(name): \(type), "
//        }
//        initialCode = String(initialCode.dropLast(2))
//        initialCode += ")"
//        return PartialSyntaxNodeString(stringLiteral: initialCode)
//    }
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
