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

    @Test func testRegistrationWithFlowRouting() async throws {
        let navigation = await FlowKit.registerNavigationSwiftUI()
        try await Task.sleep(nanoseconds: 1500000)
        #expect(await navigation.items.contains(Routes.valid.rawValue))
        #expect(await navigation.items.contains(Routes.invalid.rawValue))
        #expect(await navigation.items.contains(Routes.partial.rawValue))
    }

    @Test func testRegistrationWithoutFlowRouting() async {
        let navigation = await FlowKit.registerNavigationSwiftUI(withFlowRouting: false)
        #expect(await navigation.items.isEmpty)
    }
}

private final class InOutEmpty2: InOutProtocol {
    required init() { }
}

private final class InOutEmpty3: InOutProtocol {
    required init() { }
}

private struct InOutEmptyView: FlowViewProtocol, View {
    @EnumAllCases
    enum Out: FlowOutProtocol {
        case empty2(InOutEmpty2)
        case empty3(InOutEmpty3)
//        typealias Model = {
//            switch self {
//            case .empty2: return InOutEmpty2.self
//            case .empty3: return InOutEmpty3.self
//            }
//        }
    }

    let model: InOutEmpty
    init(model: InOutEmpty) {
        self.model = model
    }

    var body: some View {
        EmptyView()
    }
}

private struct InOutEmpty2View: FlowViewProtocol, View {
    let model: InOutEmpty2
    init(model: InOutEmpty2) {
        self.model = model
    }

    var body: some View {
        EmptyView()
    }
}

private struct InOutEmpty3View: FlowViewProtocol, View {
    let model: InOutEmpty3
    init(model: InOutEmpty3) {
        self.model = model
    }

    var body: some View {
        EmptyView()
    }
}

fileprivate enum Routes: String, Routable {
    case valid
    case partial
    case invalid
}

fileprivate final class ValidFlow: FlowProtocol {
    static let route: Routes = .valid
    let model = InOutEmpty()
    let node = InOutEmptyView.node {
        $0.empty2(InOutEmpty2()) ~ InOutEmpty2View.node
        $0.empty3(InOutEmpty3()) ~ InOutEmpty3View.node
    }
    required init() { }
}

fileprivate final class PartialMappingFlow: FlowProtocol {
    static let route: Routes = .partial
    let model = InOutEmpty2()
    let node = InOutEmptyView.node {
        $0.empty2(InOutEmpty2()) ~ InOutEmpty2View.node
    }
    required init() { }
}

fileprivate final class InvalidFlow: FlowProtocol {
    static let route: Routes = .invalid
    let model = InOutEmpty3()
    let node = InOutEmptyView.node {
        $0.empty2(InOutEmpty2()) ~ InOutEmpty2View.node
        $0.empty3(InOutEmpty3()) ~ InOutEmptyView.node
    }
    required init() { }
}
