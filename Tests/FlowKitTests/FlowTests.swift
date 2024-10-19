//
//  FlowTests.swift
//  
//
//  Created by Gerardo Grisolini on 06/03/24.
//

import XCTest
import SwiftUI
@testable import FlowKit

final class FlowTests: XCTestCase {

    func testValidFlow() async throws {
        try await ValidFlow().test()
    }

    func testPartialMappingFlow() async {
        do {
            try await PartialMappingFlow().test()
        } catch {
            XCTAssert(error is FlowError)
        }
    }

    func testInvalidFlow() async {
        do {
            try await InvalidFlow().test()
        } catch {
            XCTAssert(error is FlowError)
        }
    }

    func testRegistrationWithFlowRouting() {
        let navigation = FlowKit.registerNavigationSwiftUI()
        let assert = navigation.items.contains(Routes.valid.rawValue)
        && navigation.items.contains(Routes.invalid.rawValue)
        && navigation.items.contains(Routes.partial.rawValue)
        XCTAssertTrue(assert)
    }

    func testRegistrationWithoutFlowRouting() {
        let navigation = FlowKit.registerNavigationSwiftUI(withFlowRouting: false)
        XCTAssertTrue(navigation.items.isEmpty)
    }
}

private class InOutEmpty2: InOutProtocol {
    required init() { }
}

private class InOutEmpty3: InOutProtocol {
    required init() { }
}

private struct InOutEmptyView: FlowViewProtocol, View {
    @EnumAllCases
    enum Out: FlowOutProtocol {
        case empty2(InOutEmpty2)
        case empty3(InOutEmpty3)
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

fileprivate class ValidFlow: FlowProtocol {
    static let route: Routes = .valid
    var model = InOutEmpty()
    let node = InOutEmptyView.node {
        $0.empty2(InOutEmpty2()) ~ InOutEmpty2View.node
        $0.empty3(InOutEmpty3()) ~ InOutEmpty3View.node
    }
    required init() { }
}

fileprivate class PartialMappingFlow: FlowProtocol {
    static let route: Routes = .partial
    var model = InOutEmpty2()
    let node = InOutEmptyView.node {
        $0.empty2(InOutEmpty2()) ~ InOutEmpty2View.node
    }
    required init() { }
}

fileprivate class InvalidFlow: FlowProtocol {
    static let route: Routes = .invalid
    var model = InOutEmpty3()
    let node = InOutEmptyView.node {
        $0.empty2(InOutEmpty2()) ~ InOutEmpty2View.node
        $0.empty3(InOutEmpty3()) ~ InOutEmptyView.node
    }
    required init() { }
}
