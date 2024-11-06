import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct FlowCasesMacro: MemberMacro {
    public static func expansion<Declaration, Context>(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context) throws -> [SwiftSyntax.DeclSyntax] where Declaration : SwiftSyntax.DeclGroupSyntax, Context : SwiftSyntaxMacros.MacroExpansionContext {

            let modifier = declaration.hasPublicModifier ? "public " : ""

            guard let declaration = declaration.as(EnumDeclSyntax.self) else {
                let enumError = Diagnostic(node: node._syntaxNode, message: Diagnostics.mustBeEnum)
                context.diagnose(enumError)
                return []
            }

            guard let enumCases: [SyntaxProtocol] = declaration.memberBlock
                .children(viewMode: .fixedUp).filter({ $0.kind == .memberBlockItemList })
                .first?
                .children(viewMode: .fixedUp).filter({ $0.kind == .memberBlockItem })
                .flatMap({ $0.children(viewMode: .fixedUp).filter({ $0.kind == .enumCaseDecl })})
                .flatMap({ $0.children(viewMode: .fixedUp).filter({ $0.kind == .enumCaseElementList })})
                .flatMap({ $0.children(viewMode: .fixedUp).filter({ $0.kind == .enumCaseElement })})
            else {
                let enumError = Diagnostic(node: node._syntaxNode, message: Diagnostics.mustHaveCases)
                context.diagnose(enumError)
                return []
            }

            let caseIds: [String] = enumCases.map(\.description).map { $0.replacingOccurrences(of: ",", with: "") }
            let allCases = "\(modifier)static var allCases: [\(declaration.name)] { [\(caseIds.map { ".\($0.hasSuffix(")") ? $0.replacingOccurrences(of: ")", with: "())") : $0 )" }.joined(separator: ","))] }"
            var joinFuncs: [DeclSyntax] = []
            var updateFunc = """
\(modifier)func udpate(associatedValue: some InOutProtocol) -> Self {
    switch self {
"""
            let filteredCaseIds = caseIds.filter({ $0.hasSuffix(")") })
            for caseId in filteredCaseIds {
                let index = caseId.firstIndex(of: "(")!
                let name = caseId.prefix(upTo: index)
                var type = caseId.suffix(from: index)
                type.removeLast()
                type.removeFirst()
                updateFunc += "case .\(name)(_):\n"
                updateFunc += "guard let model = associatedValue as? \(type) else { return self }\n"
                updateFunc += "return .\(name)(model)\n"

                let joinFunc = """
\(modifier)static var \(name): (out: Self, model: \(type)) {
    (.\(name)(\(type)()), \(type)())
}
"""
                joinFuncs.append(DeclSyntax(stringLiteral: joinFunc))
            }

            if filteredCaseIds.count < caseIds.count {
                updateFunc += "default: return self"
            }

            updateFunc += """
    }
}
"""
            return [
                DeclSyntax(stringLiteral: allCases),
                DeclSyntax(stringLiteral: updateFunc)
            ] + joinFuncs
        }

    public enum Diagnostics: String, DiagnosticMessage {

        case mustBeEnum, mustHaveCases

        public var message: String {
            switch self {
            case .mustBeEnum:
                return "`@FlowCases` can only be applied to an `enum`"
            case .mustHaveCases:
                return "`@FlowCases` can only be applied to an `enum` with `case` statements"
            }
        }

        public var diagnosticID: MessageID {
            MessageID(domain: "FlowCasesMacro", id: rawValue)
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
        FlowCasesMacro.self
    ]
}
