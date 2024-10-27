import Testing
import SwiftUI
@testable import FlowKit

@MainActor
final class NavigationSwiftUITests {

    @Test func testRegisterAndNavigateToRoute() async throws {
        let sut = NavigationSwiftUI()
        sut.register(route: Routes.home) {
            EmptyView()
        }
        #expect(sut.items[Routes.home.rawValue]?() is EmptyView)

        try sut.navigate(route: Routes.home)
        try await Task.sleep(nanoseconds: 5000)
        #expect(sut.routes.last == Routes.home.rawValue)
    }

    @Test func testNavigateToView() async throws {
        let sut = NavigationSwiftUI()
        let view = EmptyView()
        sut.navigate(view: view)
        try await Task.sleep(nanoseconds: 5000)
        #expect(sut.routes.last == view.routeString)
    }

    @Test func testPop() async throws {
        let sut = NavigationSwiftUI()
        let view = EmptyView()
        sut.navigate(view: view)
        sut.pop()
        #expect(sut.routes.last != view.routeString)
//        XCTAssertFalse(sut.items[view.routeString]?() is EmptyView)
    }

    @Test func testPopToRoot() async throws {
        let sut = NavigationSwiftUI()
        sut.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 5000)
        sut.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 5000)
        sut.popToRoot()
        try await Task.sleep(nanoseconds: 5000)
        #expect(sut.routes.isEmpty)
        #expect(await sut.items.isEmpty)
    }

    @Test @MainActor func testPopToFlow() async throws {
        let sut = NavigationSwiftUI()
        sut.navigate(view: EmptyFlowView())
        try await Task.sleep(nanoseconds: 5000)
        sut.register(route: Routes.settings) {
            EmptyFlow()
        }
        _ = try sut.flow(route: Routes.settings)
        try await Task.sleep(nanoseconds: 5000)
        sut.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 5000)
        sut.popToFlow()
        try await Task.sleep(nanoseconds: 5000)
        #expect(sut.routes.count == 1)
        #expect(await sut.items.count == 2)
    }

    @Test func testPresentAndDismissView() async throws {
        let sut = NavigationSwiftUI()
        let view = EmptyView()
        sut.present(view: EmptyView())
        #expect(sut.items[view.routeString]?() is EmptyView)

        sut.dismiss()
//        XCTAssertFalse(sut.items[view.routeString]?() is EmptyView)
        #expect(sut.routes.last != view.routeString)
    }

    @Test func testActionSink() async throws {
        let sut = NavigationSwiftUI()
        var result: (navigate: Bool, present: Bool, pop: Bool, popToRoot: Bool, dismiss: Bool) = (false, false, false, false, false)
        let cancellable = sut.action.sink { action in
            switch action {
            case .navigate(_):
                result.navigate = true
            case .present(_):
                result.present = true
            case .pop(_):
                result.pop = true
            case .popToRoot:
                result.popToRoot = true
            case .dismiss:
                result.dismiss = true
            }
        }

        try await Task.sleep(nanoseconds: 5000)
        sut.navigate(routeString: ".")
        try await Task.sleep(nanoseconds: 5000)
        sut.pop()
        try await Task.sleep(nanoseconds: 5000)
        sut.present(routeString: ".")
        try await Task.sleep(nanoseconds: 5000)
        sut.dismiss()
        try await Task.sleep(nanoseconds: 5000)
        sut.popToRoot()

        cancellable.cancel()

        #expect(result.navigate && result.present && result.pop && result.popToRoot && result.dismiss)
    }
}

extension EmptyView: Navigable, Presentable { }

fileprivate enum Routes: String, Routable {
    case home
    case profile
    case settings
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

fileprivate final class EmptyFlow: FlowProtocol {
    static let route: Routes = .settings
    let model = InOutEmpty()
    let node = EmptyFlowView.node
    required init() { }
}

