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

    private var sut: Coordinator<EmptyFlow>!
    private var navigation: NavigationMock!

    override func setUp() {
        super.setUp()

        navigation = NavigationMock()
        Resolver
            .register { self.navigation }
            .implements(NavigationProtocol.self)
        sut = Coordinator(flow: EmptyFlow())
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
        navigation = nil
    }

    func testViewOut() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1000000)
            let view = self.navigation.currentView
            view?.events.send(.next(TestFlowView.Out.empty))
            view?.events.finish()
        }
        _ = try await sut.start(model: InOutEmpty())
        XCTAssertEqual(navigation.navigationAction, .navigate("TestFlowView"))
    }

    func testViewEvent() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1000000)
            let view = self.navigation.currentView
            view?.events.send(.event(TestFlowView.Event.empty))
        }
        _ = try await sut.start(model: InOutEmpty())
    }

    func testViewBack() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1000000)
            let view = navigation.currentView
            view?.back()
            view?.events.finish()
        }
        _ = try await sut.start(model: InOutEmpty())
        XCTAssertEqual(navigation.navigationAction, .pop(""))
    }

    func testViewCommit() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1000000)
            let view = navigation.currentView
            view?.commit(InOutEmpty())
            view?.events.finish()
        }
        _ = try await sut.start(model: InOutEmpty())
        XCTAssertEqual(navigation.navigationAction, .popToRoot)
    }

    func testViewOutInBehavior() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1000000)
            self.navigation.currentView?.events.send(.next(TestFlowView.Out.behavior))
            try await Task.sleep(nanoseconds: 1000000)
            self.navigation.currentView?.events.finish()
            self.navigation.routes.removeLast()
            self.navigation.currentView?.events.finish()
        }
        _ = try await sut.start(model: InOutEmpty())
        XCTAssertEqual(navigation.navigationAction, .navigate("EmptyFlowView"))
    }

    func testViewEventInBehavior() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1000000)
            let view = self.navigation.currentView
            view?.events.send(.event(TestFlowView.Event.behavior))
        }
        _ = try await sut.start(model: InOutEmpty())
    }
}

fileprivate struct TestFlowView: FlowViewProtocol, View {
    enum Out: FlowOutProtocol {
        case empty
        case behavior
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

    func onEventChanged(_ event: Event, _ model: (any InOutProtocol)?) async {
        switch event {
        case .empty:
            events.finish()
        case .behavior:
            if model is InOutModel {
                events.finish()
            }
        }
    }
}

fileprivate class InOutModel: InOutProtocol {
    required init() { }
}

fileprivate struct EmptyFlowView: FlowViewProtocol, View {
    let model: InOutModel

    init(model: InOutModel = InOutModel()) {
        self.model = model
    }

    var body: some View {
        EmptyView()
    }
}

fileprivate class EmptyFlow: FlowProtocol {
    enum Routes: String, Routable {
        case home
    }
    static let route: Routes = .home
    var model = InOutEmpty()
    let node = TestFlowView.node {
        $0.empty ~ TestFlowView.node
        $0.behavior ~ TestFlowView.node
    }
    required init() { }

    var behavior: FlowBehavior {
        .init {
            Outs { TestFlowView.Out.behavior ~ runOut }
            Events { TestFlowView.Event.behavior ~ runEvent }
        }
    }

    private func runOut(_ out: any InOutProtocol) async throws -> Results {
        .node(EmptyFlowView.node, InOutModel())
    }

    private func runEvent(_ event: any FlowEventProtocol) async throws -> any InOutProtocol {
        InOutModel()
    }
}
