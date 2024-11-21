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
        #expect(sut.items[view.routeString]?() == nil)
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
        #expect(sut.items.isEmpty)
    }

    @Test func testPopToFlow() async throws {
        let sut = NavigationSwiftUI()
        sut.navigate(view: EmptyFlowView())
        try await Task.sleep(nanoseconds: 5000)
        sut.register(route: Routes.profile) {
            EmptyFlow()
        }
        _ = try sut.flow(route: Routes.profile)
        try await Task.sleep(nanoseconds: 5000)
        sut.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 5000)
        sut.popToFlow()
        try await Task.sleep(nanoseconds: 5000)
        #expect(sut.routes.count == 1)
        #expect(sut.items.count == 2)
    }

    @Test func testPresentAndDismissView() async throws {
        let sut = NavigationSwiftUI()
        let routeString = "sheet(SwiftUI.EmptyView(), presentationDetents: [FlowKit.PresentationDetents.fraction(0.5)])"
        sut.present(.sheet(EmptyView(), detents: [.fraction(0.5)]))
        #expect(sut.routes.last == routeString)
        sut.dismiss()
        #expect(sut.routes.last != routeString)
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
        sut.present(.alert(title: "", message: ""))
        try await Task.sleep(nanoseconds: 5000)
        sut.dismiss()
        try await Task.sleep(nanoseconds: 5000)
        sut.popToRoot()

        cancellable.cancel()

        #expect(result.navigate && result.present && result.pop && result.popToRoot && result.dismiss)
    }
}

fileprivate enum Routes: String, Routable {
    case home
    case profile
}

@FlowView(InOutEmpty.self)
fileprivate struct EmptyFlowView: FlowViewProtocol, View {
    var body: some View {
        EmptyView()
    }
}

@Flow(InOutEmpty.self, route: Routes.profile)
fileprivate final class EmptyFlow: FlowProtocol {
    let node = EmptyFlowView.node
}
