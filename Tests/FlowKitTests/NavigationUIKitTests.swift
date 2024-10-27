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
        #expect(await sut.items[Routes.home.rawValue]?() is UIViewController)

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
//        XCTAssertFalse(sut.items[view.routeString]?() is UIViewController)
    }

    @Test func testPopToRoot() async throws {
        sut.navigate(view: UIViewController())
        sut.navigate(view: EmptyFlowView())
        try await Task.sleep(nanoseconds: 5000)
        sut.popToRoot()
        try await Task.sleep(nanoseconds: 5000)
        #expect(sut.routes.isEmpty)
        #expect(await sut.items.isEmpty)
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
        #expect(await sut.items.count == 2)
    }

    @Test func testPresentAndDismissView() async throws {
        let view = UIViewController()
        sut.present(view: UIViewController())
        #expect(sut.items[view.routeString]?() is UIViewController)

        sut.dismiss()
//        XCTAssertFalse(sut.items[view.routeString]?() is UIViewController)
        #expect(sut.routes.last != view.routeString)
    }
}

extension UIViewController: @retroactive Sendable {}
extension UIViewController: Navigable, Presentable { }

fileprivate enum Routes: String, Routable {
    case home
    case profile
    case settings
}

fileprivate final class EmptyFlow: FlowProtocol {
    static let route: Routes = .settings
    let model = InOutEmpty()
    let node = EmptyFlowView.node
    required init() { }
}

fileprivate class EmptyFlowView: UIViewController, FlowViewProtocol {
    let model: InOutEmpty

    required init(model: InOutEmpty = InOutEmpty()) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
