//
//  FlowTests.swift
//  
//
//  Created by Gerardo Grisolini on 06/03/24.
//

import Testing
import SwiftUI
@testable import FlowKit

final class FlowTests {

//    @Test func testRegistrationWithoutFlowRouting() async throws {
//        let navigation = await FlowKit.registerNavigationUIKit(navigationController: UINavigationController(), withFlowRouting: false)
//        #expect(await navigation.items.isEmpty)
//    }

    @Test func testRegistrationWithFlowRouting() async throws {
        let navigation = await FlowKit.registerNavigationSwiftUI()
        #expect(await navigation.items.contains(Routes.valid.rawValue))
        #expect(await navigation.items.contains(Routes.invalid.rawValue))
        #expect(await navigation.items.contains(Routes.partial.rawValue))
    }

    @Test func testValidFlow() async throws {
        try await ValidFlow().test()
    }

    @Test func testPartialMappingFlow() async {
        do {
            try await PartialMappingFlow().test()
        } catch {
            #expect(error is FlowError)
        }
    }

    @Test func testInvalidFlow() async {
        do {
            try await InvalidFlow().test()
        } catch {
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

fileprivate enum Routes: String, Routable {
    case valid
    case partial
    case invalid
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
