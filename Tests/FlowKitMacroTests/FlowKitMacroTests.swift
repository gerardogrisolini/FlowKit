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

    @Test func flowMacroTest() {
#if canImport(FlowMacro)
        assertMacroExpansion(#"""
@Flow(InOutEmpty.self, route: Routes.home)
final class TestFlow: FlowProtocol {
    let node = TestFlowView.node {
        $0.empty ~ EmptyFlowView.node
        $0.behavior ~ NotEmptyFlowView.node
    }
}
"""#,
            expandedSource: #"""
@Flow(InOutEmpty.self, route: Routes.home)
final class TestFlow: FlowProtocol {
    let node = TestFlowView.node {
        $0.empty ~ EmptyFlowView.node
        $0.behavior ~ NotEmptyFlowView.node
    }
    static let route = Routes.home

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

    @Test func flowViewMacroTest() {
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

    @Test func flowCasesMacroTest() {
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
