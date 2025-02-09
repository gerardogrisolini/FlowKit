//
//  FlowRouterUIKitTests.swift
//  FlowKitTests
//
//  Created by Gerardo Grisolini on 26/11/24.
//

#if canImport(UIKit)
import Testing
import UIKit
@testable import FlowKit

@MainActor
final class FlowRouterUIKitTests {

    @Test func testPopToFlow() async throws {
        let sut = FlowRouterUIKit()
        sut.navigationController = UINavigationController()
        sut.navigate(view: EmptyFlowView())
        sut.register(route: Routes.home, for: EmptyFlow.init)
        _ = try sut.flow(route: Routes.home)
        sut.navigate(view: UIViewController())
        sut.popToFlow()
        #expect(sut.routes.count == 1)
        #expect(sut.items.count == 2)
    }
}

fileprivate enum Routes: Routable {
    case home
}

@Flow(InOutEmpty.self, route: Routes.home)
fileprivate final class EmptyFlow: FlowProtocol {
    let node = EmptyFlowView.node
}

@FlowView(InOutEmpty.self)
fileprivate final class EmptyFlowView: UIViewController, FlowViewProtocol {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
