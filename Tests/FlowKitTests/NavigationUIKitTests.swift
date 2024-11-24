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
        await sut.register(route: Routes.home, with: { _ in await UIViewController() })
        await sut.register(route: Routes.settings, with: { _ in EmptyFlow() })
        #expect(await sut.items.getValue(for: Routes.home.routeString) is UIViewController)

        try await sut.navigate(route: Routes.home)
        #expect(sut.routes.last == Routes.home.routeString)
    }

    @Test func testNavigateToView() async throws {
        let view = UIViewController()
        await sut.navigate(view: view)
        #expect(sut.routes.last == view.routeString)
    }

    @Test func testPop() async throws {
        let view = UIViewController()
        await sut.navigate(view: view)
        await sut.pop()
        #expect(sut.routes.last != view.routeString)
        #expect(await sut.items.getValue(for: view.routeString) == nil)
    }

    @Test func testPopToRoot() async throws {
        await sut.navigate(view: UIViewController())
        await sut.navigate(view: EmptyFlowView())
        await sut.popToRoot()
        #expect(sut.routes.isEmpty)
        #expect(await sut.items.isEmpty)
    }

    @Test func testPopToFlow() async throws {
        await sut.navigate(view: EmptyFlowView())
        await sut.register(route: Routes.settings, with: { _ in EmptyFlow() })
        _ = try await sut.flow(route: Routes.settings)
        await sut.navigate(view: UIViewController())
        await sut.popToFlow()
        #expect(sut.routes.count == 1)
        #expect(await sut.items.count == 2)
    }

    @Test func testPresentAndDismissView() async throws {
        let mode: PresentMode = .sheet(UIViewController())
        sut.present(mode)
        #expect(sut.routes.last == mode.routeString)
        #expect(sut.presentMode == mode)
        sut.dismiss()
        #expect(sut.routes.last != mode.routeString)
    }

    @Test func testPresentAlert() async throws {
        let mode: PresentMode = .alert(title: "Title", message: "Message")
        sut.present(mode)
        #expect(sut.routes.last == nil)
        #expect(sut.presentMode == mode)
    }

    @Test func testPresentConfirmationDialog() async throws {
        let mode: PresentMode = .confirmationDialog(title: "Title", actions: [])
        sut.present(mode)
        #expect(sut.routes.last == nil)
        #expect(sut.presentMode == mode)
    }
}

fileprivate enum Routes: Routable {
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
