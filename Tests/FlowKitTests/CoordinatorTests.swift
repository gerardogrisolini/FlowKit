//
//  CoordinatorTests.swift
//  
//
//  Created by Gerardo Grisolini on 04/03/24.
//

import XCTest
import Combine
import SwiftUI
@testable import FlowKit

final class CoordinatorTests: XCTestCase {

    private var sut: Coordinator<EmptyFlow>!
    private var navigation: NavigationMock!

    override func setUp() {
        navigation = NavigationMock()
        Resolver
            .register { self.navigation }
            .implements(NavigationProtocol.self)
            .scope(.shared)
        sut = Coordinator(flow: EmptyFlow())
    }

    override func tearDown() {
        sut = nil
        navigation = nil
    }

    func testViewOut() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1000000)
            let view = self.navigation.currentView
            view?.events.send(.next(EmptyFlowView.Out.empty))
            view?.events.finish()
        }
        _ = try await sut.start(model: InOutEmpty())
        XCTAssertEqual(navigation.navigationAction, .navigate("EmptyFlowView"))
    }

    func testViewEvent() async throws {
        Task {
            try await Task.sleep(nanoseconds: 1000000)
            let view = self.navigation.currentView
            view?.events.send(.event(EmptyFlowView.Event.empty))
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
}

fileprivate struct EmptyFlowView: FlowViewProtocol, View {
    enum Out: FlowOutProtocol {
        case empty
    }
    enum Event: FlowEventProtocol {
        case empty
    }

    let model: InOutEmpty

    init(model: InOutEmpty = InOutEmpty()) {
        self.model = model
    }

    var body: some View {
        EmptyView()
    }

    func onEventChanged(_ event: Event, _ model: (any InOutProtocol)?) async {
        events.finish()
    }
}

fileprivate class EmptyFlow: FlowProtocol {
    enum Routes: String, Routable {
        case home
    }
    static let route: Routes = .home
    var model = InOutEmpty()
    let node = EmptyFlowView.node {
        $0.empty ~ EmptyFlowView.node {
            $0.empty ~ EmptyFlowView.node
        }
    }
    required init() { }
}

fileprivate class NavigationMock: NavigationProtocol {
    var navigationController: UINavigationController?
    let action = PassthroughSubject<NavigationAction, Never>()
    var routes: [String] = []
    var items = NavigationItems()

    var navigationAction: NavigationAction? = nil
    var currentView: (any FlowViewProtocol)? {
        guard let route = routes.last, let view = items[route]?() as? any FlowViewProtocol else {
            return nil
        }
        return view
    }

    required init() { }

    func navigate(route: some Routable) throws {
        navigate(routeString: "\(route)")
    }

    func navigate(routeString: String) {
        routes.append(routeString)
        navigationAction = .navigate(routeString)
    }

    func present(route: some Routable) throws {
        present(routeString: "\(route)")
    }

    func present(routeString: String) {
        routes.append(routeString)
        navigationAction = .present(routeString)
    }

    func pop() {
        routes.removeLast()
        navigationAction = .pop("")
    }
    
    func popToFlow() {
        routes = []
        navigationAction = .popToRoot
    }
    
    func popToRoot() {
        routes = []
        navigationAction = .popToRoot
    }
    
    func dismiss() {
        routes.removeLast()
        navigationAction = .dismiss
    }
}
