//
//  CoordinatorTests.swift
//  
//
//  Created by Gerardo Grisolini on 04/03/24.
//

import XCTest
import SwiftUI
@testable import FlowKit

final class CoordinatorTests: XCTestCase {

    private var sut: Coordinator<TestFlow>!
    private var navigation: NavigationMock!

    override func setUp() {
        super.setUp()

        navigation = NavigationMock()
        Resolver
            .register { self.navigation }
            .implements(NavigationProtocol.self)
        sut = Coordinator(flow: TestFlow())
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
        navigation = nil
    }

    func testViewCommit() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1500000)
            let view = navigation.currentView
            view?.commit(InOutEmpty(), toRoot: true)
            try await Task.sleep(nanoseconds: 500000)
            await view?.events.finish()
        }
        _ = try await sut.start(model: InOutEmpty())
        XCTAssertEqual(navigation.navigationAction, .popToRoot)
    }

    func testViewOut() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1500000)
            await navigation.currentView?.events.send(.next(TestFlowView.Out.empty))
            try await Task.sleep(nanoseconds: 150000000)
            await navigation.currentView?.events.finish()
            navigation.routes.removeLast()
            await navigation.currentView?.events.finish()
        }
        _ = try await sut.start(model: InOutEmpty())
        XCTAssertEqual(navigation.navigationAction, .navigate("EmptyFlowView"))
    }

    func testViewEvent() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1500000)
            let view = navigation.currentView
            await view?.events.send(.event(TestFlowView.Event.empty))
        }
        _ = try await sut.start(model: InOutEmpty())
    }

    func testViewOutInBehavior() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1500000)
            await navigation.currentView?.events.send(.next(TestFlowView.Out.behavior(InOutModel())))
            try await Task.sleep(nanoseconds: 150000000)
            await navigation.currentView?.events.finish()
            navigation.routes.removeLast()
            await navigation.currentView?.events.finish()
        }
        _ = try await sut.start(model: InOutEmpty())
        XCTAssertEqual(navigation.navigationAction, .navigate("EmptyFlowView"))
    }

    func testViewEventInBehavior() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1500000)
            await navigation.currentView?.events.send(.event(TestFlowView.Event.behavior))
        }
        _ = try await sut.start(model: InOutEmpty())
    }

    func testViewBack() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1000000)
            let view = navigation.currentView
            view?.back()
            try await Task.sleep(nanoseconds: 500000)
            await view?.events.finish()
        }
        _ = try await sut.start(model: InOutEmpty())
        XCTAssertEqual(navigation.navigationAction, .pop(""))
    }
}

fileprivate struct TestFlowView: FlowViewProtocol, View {
    @EnumAllCases
    enum Out: FlowOutProtocol {
        case empty
        case behavior(InOutModel)
    }
    enum Event: FlowEventProtocol {
        case empty
        case behavior
    }

    let model: InOutEmpty
    init(model: InOutEmpty = InOutEmpty()) {
        self.model = model
    }

    var body: some View {
        EmptyView()
    }

    func onEventChanged(event: Event, model: some InOutProtocol) async {
        switch event {
        case .empty:
            await events.finish()
        case .behavior:
            if model is InOutModel {
                await events.finish()
            }
        }
    }
}

fileprivate class InOutModel: InOutProtocol {
    required init() { }
}

fileprivate struct NotEmptyFlowView: FlowViewProtocol, View {
    let model: InOutModel
    var body: some View {
        EmptyView()
    }
}

fileprivate struct EmptyFlowView: FlowViewProtocol, View {
    let model: InOutEmpty
    var body: some View {
        EmptyView()
    }
}

fileprivate enum Routes: String, Routable {
    case home, empty
}

fileprivate class TestFlow: FlowProtocol {
    static let route: Routes = .home
    var model = InOutEmpty()
    let node = TestFlowView.node {
        $0.empty ~ EmptyFlowView.node
        $0.behavior(InOutModel()) ~ NotEmptyFlowView.node
    }
    required init() { }

    var behavior: FlowBehavior {
        .init {
            Outs { TestFlowView.Out.behavior(InOutModel()) ~ runOut }
            Events { TestFlowView.Event.behavior ~ runEvent }
        }
    }

    private func runOut(_ out: any InOutProtocol) async throws -> Results {
        .node(EmptyFlowView.node, InOutEmpty())
    }

    private func runEvent(_ event: any FlowEventProtocol) async throws -> any InOutProtocol {
        InOutModel()
    }
}
