//
//  CoordinatorTests.swift
//  
//
//  Created by Gerardo Grisolini on 04/03/24.
//

import Testing
import SwiftUI
@testable import FlowKit

@MainActor
final class CoordinatorTests {

    private func startCoordinator(_ navigation: NavigationMock) async throws {
        try await Coordinator(flow: TestFlow(), navigation: navigation).start(model: InOutEmpty())
    }
    
    @Test func testViewCommit() async throws {
        let navigation = NavigationMock()
        Task { [navigation] in
            try await Task.sleep(nanoseconds: 1500000)
            let view = navigation.currentView
            view?.commit(InOutEmpty(), toRoot: true)
            try await Task.sleep(nanoseconds: 500000)
            await view?.events.finish()
        }
        try await startCoordinator(navigation)
        #expect(navigation.navigationAction == .popToRoot)
    }

    @Test func testViewOut() async throws {
        let navigation = NavigationMock()
        Task { [navigation] in
            try await Task.sleep(nanoseconds: 1500000)
            await navigation.currentView?.events.send(.next(TestFlowView.Out.empty))
            try await Task.sleep(nanoseconds: 15000000)
            await navigation.currentView?.events.finish()
            navigation.routes.removeLast()
            await navigation.currentView?.events.finish()
        }
        try await startCoordinator(navigation)
        #expect(navigation.navigationAction == .navigate("EmptyFlowView"))
    }

    @Test func testViewEvent() async throws {
        let navigation = NavigationMock()
        Task { [navigation] in
            try await Task.sleep(nanoseconds: 1500000)
            let view = navigation.currentView
            await view?.events.send(.event(TestFlowView.Event.empty))
        }
        try await startCoordinator(navigation)
    }

    @Test func testViewOutInBehavior() async throws {
        let navigation = NavigationMock()
        Task { [navigation] in
            try await Task.sleep(nanoseconds: 1500000)
            await navigation.currentView?.events.send(.next(TestFlowView.Out.behavior(InOutModel())))
            try await Task.sleep(nanoseconds: 15000000)
            await navigation.currentView?.events.finish()
            navigation.routes.removeLast()
            await navigation.currentView?.events.finish()
        }
        try await startCoordinator(navigation)
        #expect(navigation.navigationAction == .navigate("EmptyFlowView"))
    }

    @Test func testViewEventInBehavior() async throws {
        let navigation = NavigationMock()
        Task { [navigation] in
            try await Task.sleep(nanoseconds: 1500000)
            await navigation.currentView?.events.send(.event(TestFlowView.Event.behavior))
        }
        try await startCoordinator(navigation)
    }

    @Test func testViewBack() async throws {
        let navigation = NavigationMock()
        Task { [navigation] in
            try await Task.sleep(nanoseconds: 1000000)
            let view = navigation.currentView
            view?.back()
            try await Task.sleep(nanoseconds: 5000000)
            await view?.events.finish()
        }
        try await startCoordinator(navigation)
        #expect(navigation.navigationAction == .pop(""))
    }
}

fileprivate struct TestFlowView: FlowViewProtocol, View {
    let _events = AsyncThrowingSubject<CoordinatorEvent>()
    var events: AsyncThrowingSubject<CoordinatorEvent> {
        get async { _events }
    }

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

fileprivate final class InOutModel: InOutProtocol {
    required init() { }
}

fileprivate struct NotEmptyFlowView: FlowViewProtocol, View {
    let model: InOutModel
    var body: some View {
        EmptyView()
    }
}

fileprivate struct EmptyFlowView: FlowViewProtocol, View {
    let _events = AsyncThrowingSubject<CoordinatorEvent>()
    var events: AsyncThrowingSubject<CoordinatorEvent> {
        get async { _events }
    }
    let model: InOutEmpty
    var body: some View {
        EmptyView()
    }
}

fileprivate enum Routes: String, Routable {
    case home, empty
}

fileprivate final class TestFlow: FlowProtocol {
    static let route: Routes = .home
    let model = InOutEmpty()
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
