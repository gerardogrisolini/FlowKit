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
            var updateFunc = """
\(modifier)func udpate(associatedValue: some InOutProtocol) -> Self {
    switch self {
"""
            for caseId in caseIds.filter({ $0.hasSuffix(")") }) {
                let index = caseId.firstIndex(of: "(")!
                let name = caseId.prefix(upTo: index)
                var type = caseId.suffix(from: index)
                type.removeLast()
                type.removeFirst()
                updateFunc += "case .\(name)(_):"
                updateFunc += "guard let model = associatedValue as? \(type) else { return self }"
                updateFunc += "return .\(name)(model)"
            }
            updateFunc += """
    default: return self
    }
}
"""
            return [
                DeclSyntax(stringLiteral: allCases),
                DeclSyntax(stringLiteral: updateFunc)
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

