//
//  FlowTests.swift
//  
//
//  Created by Gerardo Grisolini on 06/03/24.
//

import Testing
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
@testable import FlowKit

final class FlowTests {

    @Test @MainActor func testRegistrationWithFlowRouting() {
#if canImport(UIKit)
        let navigation2 = FlowKit.registerNavigationUIKit(navigationController: UINavigationController(), withFlowRouting: false)
        #expect(navigation2.items.isEmpty)
#endif

        let navigation1 = FlowKit.registerNavigationSwiftUI()
        #expect(navigation1.items.contains(Routes.valid.routeString))
        #expect(navigation1.items.contains(Routes.invalid.routeString))
        #expect(navigation1.items.contains(Routes.partial.routeString))
    }

    @Test func testValidFlow() async throws {
        try await ValidFlow().test(route: .valid)
    }

    @Test func testPartialMappingFlow() async {
        do {
            try await PartialMappingFlow().test(route: .partial)
        } catch {
            print(error)
            #expect(error is FlowError)
        }
    }

    @Test func testInvalidFlow() async {
        do {
            try await InvalidFlow().test(route: .invalid)
        } catch {
            print(error)
            #expect(error is FlowError)
        }
    }

    @Test func testInvalidParameterOfFlow() async {
        do {
            try await ValidFlow().test(route: .custom(InOutEmpty3()))
        } catch {
            print(error)
            #expect(error is FlowError)
        }
    }
}

final class InOutEmpty2: InOutProtocol {
    required init() { }
}

final class InOutEmpty3: InOutProtocol {
    required init() { }
}

@FlowView(InOutEmpty.self)
struct InOutEmptyView: FlowViewProtocol, View {
    @FlowCases
    enum Out: FlowOutProtocol {
        case empty2(InOutEmpty2)
        case empty3(InOutEmpty3)
    }

    var body: some View {
        EmptyView()
    }
}

@FlowView(InOutEmpty2.self)
struct InOutEmpty2View: FlowViewProtocol, View {
    var body: some View {
        EmptyView()
    }
}

@FlowView(InOutEmpty3.self)
struct InOutEmpty3View: FlowViewProtocol, View {
    var body: some View {
        EmptyView()
    }
}

@FlowCases
fileprivate enum Routes: Routable {
    case valid
    case partial
    case invalid
    case custom(InOutEmpty3)
}

@Flow(InOutEmpty.self, route: Routes.valid)
fileprivate final class ValidFlow: FlowProtocol {
    let node = InOutEmptyView.node {
        $0.empty2 ~ InOutEmpty2View.node
        $0.empty3 ~ InOutEmpty3View.node
    }
}

@Flow(InOutEmpty2.self, route: Routes.partial)
fileprivate final class PartialMappingFlow: FlowProtocol {
    let node = InOutEmptyView.node {
        $0.empty2 ~ InOutEmpty2View.node
    }
}

@Flow(InOutEmpty3.self, route: Routes.invalid)
fileprivate final class InvalidFlow: FlowProtocol {
    let node = InOutEmptyView.node {
        $0.empty2 ~ InOutEmpty2View.node
        $0.empty3(InOutEmpty3()) ~ InOutEmptyView.node
    }
}
