#if canImport(UIKit)
import Testing
import UIKit
@testable import FlowKit

@MainActor
final class NavigationUIKitTests {

    var sut: NavigationUIKit!

    init() async throws {
        sut = NavigationUIKit()
        sut.navigationController = UINavigationController()
    }

    deinit {
        sut = nil
    }

    @Test func testRegisterAndNavigateToRoute() async throws {
        let view = UIViewController()
        sut.register(route: Routes.home) { view }
        #expect(sut.items[Routes.home.rawValue]?() is UIViewController)

        try sut.navigate(route: Routes.home)
        #expect(sut.routes.last == Routes.home.rawValue)
    }

    @Test func testNavigateToView() async throws {
        let view = UIViewController()
        sut.navigate(view: view)
        try await Task.sleep(nanoseconds: 5000)
        #expect(sut.routes.last == view.routeString)
    }

    @Test func testPop() async throws {
        let view = UIViewController()
        sut.navigate(view: view)
        sut.pop()
        #expect(sut.routes.last != view.routeString)
        #expect(sut.items[view.routeString]?() == nil)
    }

    @Test func testPopToRoot() async throws {
        sut.navigate(view: UIViewController())
        sut.navigate(view: EmptyFlowView())
        try await Task.sleep(nanoseconds: 5000)
        sut.popToRoot()
        try await Task.sleep(nanoseconds: 5000)
        #expect(sut.routes.isEmpty)
        #expect(sut.items.isEmpty)
    }

    @Test func testPopToFlow() async throws {
        sut.navigate(view: EmptyFlowView())
        try await Task.sleep(nanoseconds: 5000)
        sut.register(route: Routes.settings) {
            EmptyFlow()
        }
        _ = try sut.flow(route: Routes.settings)
        try await Task.sleep(nanoseconds: 5000)
        sut.navigate(view: UIViewController())
        try await Task.sleep(nanoseconds: 5000)
        sut.popToFlow()
        try await Task.sleep(nanoseconds: 5000)
        #expect(sut.routes.count == 1)
        #expect(sut.items.count == 2)
    }

    @Test func testPresentAndDismissView() async throws {
        let mode: PresentMode = .sheet(UIViewController())
        sut.present(mode)
        #expect(sut.routes.last == mode.routeString)
        sut.dismiss()
        #expect(sut.routes.last != mode.routeString)
    }
}

fileprivate enum Routes: String, Routable {
    case home
    case settings
}

@Flow(InOutEmpty.self, route: Routes.settings)
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
