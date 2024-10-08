import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

public struct EnumAllCasesMacro: MemberMacro {
    public static func expansion<Declaration, Context>(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {

            guard let declaration = declaration.as(EnumDeclSyntax.self) else {
                let enumError = Diagnostic(node: node._syntaxNode, message: Diagnostics.mustBeEnum)
                context.diagnose(enumError)
                return []
            }

            guard let enumCases: [SyntaxProtocol] = declaration.memberBlock
                .children(viewMode: .fixedUp).filter({ $0.kind == .memberDeclList })
                .first?
                .children(viewMode: .fixedUp).filter({ $0.kind == SyntaxKind.memberDeclListItem })
                .flatMap({ $0.children(viewMode: .fixedUp).filter({ $0.kind == .enumCaseDecl })})
                .flatMap({ $0.children(viewMode: .fixedUp).filter({ $0.kind == .enumCaseElementList })})
                .flatMap({ $0.children(viewMode: .fixedUp).filter({ $0.kind == .enumCaseElement })})
            else {
                let enumError = Diagnostic(node: node._syntaxNode, message: Diagnostics.mustHaveCases)
                context.diagnose(enumError)
                return []
            }

            let caseIds: [String] = enumCases.map(\.description).map { $0.replacingOccurrences(of: ",", with: "") }
            let modifier = declaration.hasPublicModifier ? "public " : ""
            let allCases = "\(modifier)static var allCases: [\(declaration.name)] { [\(caseIds.map { ".\($0.hasSuffix(")") ? $0.replacingOccurrences(of: ")", with: "())") : $0 )" }.joined(separator: ","))] }"

            return [
                DeclSyntax(stringLiteral: allCases)
            ]
        }

    public enum Diagnostics: String, DiagnosticMessage {

        case mustBeEnum, mustHaveCases

        public var message: String {
            switch self {
            case .mustBeEnum:
                return "`@EnumAllCasesMacro` can only be applied to an `enum`"
            case .mustHaveCases:
                return "`@EnumAllCasesMacro` can only be applied to an `enum` with `case` statements"
            }
        }

        public var diagnosticID: MessageID {
            MessageID(domain: "EnumAllCasesMacro", id: rawValue)
        }

        public var severity: DiagnosticSeverity { .error }
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
        EnumAllCasesMacro.self,
    ]
}

