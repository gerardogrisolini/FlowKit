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
        let app = FlowApp()
        let navigation = app.register(navigation: .swiftUI, withFlowRouting: true)
        let assert = navigation.items.contains(Routes.valid.rawValue)
        && navigation.items.contains(Routes.invalid.rawValue)
        && navigation.items.contains(Routes.partial.rawValue)
        XCTAssertTrue(assert)
    }

    func testRegistrationWithoutFlowRouting() {
        let app = FlowApp()
        let navigation = app.register(navigation: .swiftUI, withFlowRouting: false)
        XCTAssertTrue(navigation.items.isEmpty)
    }
}

fileprivate class FlowApp: FlowKitApp { }

fileprivate class InOutModel: InOutProtocol {
    required init() { }
}

fileprivate struct TestFlowView: FlowViewProtocol, View {
    enum Out: FlowOutProtocol {
        case empty
        case behavior
    }
    let model: InOutModel

    init(model: InOutModel = InOutModel()) {
        self.model = model
    }

    var body: some View {
        EmptyView()
    }
}

fileprivate struct TestEmptyFlowView: FlowViewProtocol, View {
    let model: InOutModel
    init(model: InOutModel = InOutModel()) {
        self.model = model
    }

    var body: some View {
        EmptyView()
    }
}

fileprivate struct EmptyFlowView: FlowViewProtocol, View {
    let model: InOutEmpty
    init(model: InOutEmpty = InOutEmpty()) {
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
    var model = InOutModel()
    let node = TestFlowView.node {
        $0.empty ~ TestEmptyFlowView.node
        $0.behavior ~ TestEmptyFlowView.node
    }
    required init() { }
}

fileprivate class PartialMappingFlow: FlowProtocol {
    static let route: Routes = .partial
    var model = InOutModel()
    let node = TestFlowView.node {
        $0.empty ~ TestFlowView.node
        $0.behavior ~ TestEmptyFlowView.node
    }
    required init() { }
}

fileprivate class InvalidFlow: FlowProtocol {
    static let route: Routes = .invalid
    var model = InOutModel()
    let node = TestFlowView.node {
        $0.empty ~ EmptyFlowView.node
        $0.behavior ~ TestEmptyFlowView.node
    }
    required init() { }
}
