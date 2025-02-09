//
//  CoordinatorTests.swift
//  FlowKitTests
//
//  Created by Gerardo Grisolini on 04/03/24.
//

import Testing
import SwiftUI
@testable import FlowKit

@MainActor
final class CoordinatorTests {

    private func startCoordinator(_ router: RouterMock) async throws {
        try await Coordinator(flow: TestFlow(), router: router).start()
    }
    
    @Test func testViewCommit() async throws {
        let router = RouterMock()
        Task { [router] in
            try await Task.sleep(nanoseconds: 150000000)
            let view = router.currentView
            view?.commit(InOutEmpty(), toRoot: true)
            view?.events.finish()
        }
        try await startCoordinator(router)
        #expect(router.routerAction == RouterAction.popToRoot)
    }

    @Test func testViewOut() async throws {
        let router = RouterMock()
        Task { [router] in
            try await Task.sleep(nanoseconds: 150000000)
            router.currentView?.events.send(.next(TestFlowView.Out.empty))
            try await Task.sleep(nanoseconds: 150000000)
            router.currentView?.events.finish()
            router.routes.removeLast()
            await router.setView()
            router.currentView?.events.finish()
        }
        try await startCoordinator(router)
        #expect(router.routerAction == .navigate("EmptyFlowView"))
    }

    @Test func testViewEvent() async throws {
        let router = RouterMock()
        Task { [router] in
            try await Task.sleep(nanoseconds: 150000000)
            router.currentView?.events.send(.event(TestFlowView.Event.empty))
        }
        try await startCoordinator(router)
    }

    @Test func testViewOutInBehavior() async throws {
        let router = RouterMock()
        Task { [router] in
            try await Task.sleep(nanoseconds: 150000000)
            router.currentView?.events.send(.next(TestFlowView.Out.behavior(InOutModel())))
            try await Task.sleep(nanoseconds: 150000000)
            router.currentView?.events.finish()
            router.routes.removeLast()
            await router.setView()
            router.currentView?.events.finish()
        }
        try await startCoordinator(router)
        #expect(router.routerAction == .navigate("EmptyFlowView"))
    }

    @Test func testViewEventInBehavior() async throws {
        let router = RouterMock()
        Task { [router] in
            try await Task.sleep(nanoseconds: 150000000)
            router.currentView?.events.send(.event(TestFlowView.Event.behavior))
        }
        try await startCoordinator(router)
    }

    @Test func testViewBack() async throws {
        let router = RouterMock()
        Task { [router] in
            try await Task.sleep(nanoseconds: 150000000)
            let view = router.currentView
            view?.back()
            view?.events.finish()
        }
        try await startCoordinator(router)
        #expect(router.routerAction == .pop("TestFlowView"))
    }
}

@FlowView(InOutEmpty.self)
fileprivate struct TestFlowView: FlowViewProtocol, View {
    @FlowCases
    enum Out: FlowOutProtocol {
        case empty
        case behavior(InOutModel)
    }
    enum Event: FlowEventProtocol {
        case empty
        case behavior
    }

    var body: some View {
        EmptyView()
    }

    func onEventChanged(event: Event, model: some InOutProtocol) async {
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

fileprivate final class InOutModel: InOutProtocol {
    required init() { }
}

@FlowView(InOutModel.self)
fileprivate struct NotEmptyFlowView: FlowViewProtocol, View {
    var body: some View {
        EmptyView()
    }
}

@FlowView(InOutEmpty.self)
fileprivate struct EmptyFlowView: FlowViewProtocol, View {
    var body: some View {
        EmptyView()
    }
}

fileprivate enum Routes: String, Routable {
    case home, empty
}

@Flow(InOutEmpty.self, route: Routes.home)
fileprivate final class TestFlow: FlowProtocol {
    let node = TestFlowView.node {
        $0.empty ~ EmptyFlowView.node
        $0.behavior ~ NotEmptyFlowView.node
    }

    fileprivate func runOut(_ out: any InOutProtocol) async throws -> Results {
        .node(EmptyFlowView.node, InOutEmpty())
    }

    fileprivate func runEvent(_ event: any FlowEventProtocol) async throws -> any InOutProtocol {
        InOutModel()
    }
}
