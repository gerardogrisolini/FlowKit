import Testing
import SwiftUI
@testable import FlowKit

@MainActor
final class NavigationSwiftUITests {

    @Test func testPopToFlow() async throws {
        let sut = FlowNavigationSwiftUI()
        sut.navigate(view: FlowViewTest())
        sut.register(route: Routes.home) {
            FlowTest()
        }
        _ = try sut.flow(route: Routes.home)
        sut.navigate(view: EmptyView())
        sut.popToFlow()
        #expect(sut.routes.count == 1)
        #expect(sut.items.count == 2)
    }
}

fileprivate enum Routes: Routable {
    case home
}

@FlowView(InOutEmpty.self)
struct FlowViewTest: FlowViewProtocol, View {
    var body: some View {
        EmptyView()
    }
}

@Flow(InOutEmpty.self, route: Routes.home)
fileprivate final class FlowTest: FlowProtocol {
    let node = FlowViewTest.node
}
