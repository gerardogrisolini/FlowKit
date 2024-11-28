//
//  FlowKitMacroTests.swift
//  FlowViewMacro
//
//  Created by Gerardo Grisolini on 04/11/24.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing
#if canImport(FlowCasesMacro)
import FlowMacro
import FlowViewMacro
import FlowCasesMacro

let providingMacro: [String: Macro.Type] = [
    "Flow": FlowMacro.self,
    "FlowView": FlowViewMacro.self,
    "FlowCases": FlowCasesMacro.self
]
#endif

struct FlowKitMacroTests {

    @Test func flowMacroTest() throws {
#if canImport(FlowMacro)
    assertMacroExpansion(#"""
        @Flow(InOutEmpty.self, route: Routes.valid)
        final class ValidFlow: FlowProtocol {
            let node = InOutEmptyView.node {
                $0.empty2 ~ InOutEmpty2View.node
                $0.empty3 ~ InOutEmpty3View.node
            }
        }
        """#,
    expandedSource: #"""
        @Flow(InOutEmpty.self, route: Routes.valid)
        final class ValidFlow: FlowProtocol {
            let node = InOutEmptyView.node {
                $0.empty2 ~ InOutEmpty2View.node
                $0.empty3 ~ InOutEmpty3View.node
            }
            static let route = Routes.valid

            typealias RouteModel = InOutEmpty

            typealias Model = InOutEmpty

            init() {
            }
        }
        """#,
    macros: providingMacro
)
#else
        withKnownIssue("macros are only supported when running tests for the host platform") { }
#endif
}

    @Test func flowViewMacroTest() throws {
#if canImport(FlowViewMacro)
    assertMacroExpansion(#"""
        @FlowView(InOutEmpty.self)
        struct EmptyFlowView: FlowViewProtocol, View {
            var body: some View {
                EmptyView()
            }
        }
        """#,
    expandedSource: #"""
        @FlowView(InOutEmpty.self)
        struct EmptyFlowView: FlowViewProtocol, View {
            var body: some View {
                EmptyView()
            }
            let events = AsyncThrowingSubject<CoordinatorEvent>()

            let model: InOutEmpty

            init(model: InOutEmpty = InOutEmpty()) {
                self.model = model
            }
        }
        """#,
    macros: providingMacro
)
#else
        withKnownIssue("macros are only supported when running tests for the host platform") { }
#endif
}

    @Test func flowViewClassMacroTest() throws {
#if canImport(FlowViewMacro)
    assertMacroExpansion(#"""
        final class EmptyFlowView: UIViewController, FlowViewProtocol {
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        """#,
    expandedSource: #"""
        final class EmptyFlowView: UIViewController, FlowViewProtocol {
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            let events = AsyncThrowingSubject<CoordinatorEvent>()

            let model: InOutEmpty

            required init(model: InOutEmpty = InOutEmpty()) {
                self.model = model
                super.init(nibName: nil, bundle: nil)
            }
        }
        """#,
    macros: providingMacro
)
#else
        withKnownIssue("macros are only supported when running tests for the host platform") { }
#endif
}

    @Test func flowCasesMacroTest() throws {
#if canImport(FlowCasesMacro)
    assertMacroExpansion(#"""
        @FlowCases
        enum Out: FlowOutProtocol {
            case empty
            case show(InOutModel)
        }
        """#,
    expandedSource: #"""
        @FlowCases
        enum Out: FlowOutProtocol {
            case empty
            case show(InOutModel)
            static var allCases: [Out] {
                [.empty, .show(InOutModel())]
            }

            func udpate(associatedValue: some InOutProtocol) -> Self {
                switch self {
                case .show(_):
                    guard let model = associatedValue as? InOutModel else {
                        return self
                    }
                    return .show(model)
                default:
                    return self
                }
            }

            static var show: (out: Self, model: InOutModel) {
                (.show(InOutModel()), InOutModel())
            }
        }
        """#,
    macros: providingMacro
    )
#else
        withKnownIssue("macros are only supported when running tests for the host platform") { }
#endif
    }
}
