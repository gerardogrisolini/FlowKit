import Testing
import SwiftUI
@testable import FlowKit

@MainActor
final class NavigationSwiftUITests {

    @Test func testRegisterAndNavigateToRoute() async throws {
        let sut = NavigationSwiftUI()
        sut.register(route: Routes.home) { _ in
            EmptyView()
        }
        #expect(sut.items.getValue(for: Routes.home.routeString) is EmptyView)

        try sut.navigate(route: Routes.home)
        #expect(sut.routes.last == Routes.home.routeString)
    }

    @Test func testNavigateToView() async throws {
        let sut = NavigationSwiftUI()
        let view = EmptyView()
        sut.navigate(view: view)
        #expect(sut.routes.last == view.routeString)
    }

    @Test func testPop() async throws {
        let sut = NavigationSwiftUI()
        let view = EmptyView()
        sut.navigate(view: view)
        sut.pop()
        #expect(sut.routes.last != view.routeString)
        #expect(sut.items.getValue(for: view.routeString) == nil)
    }

    @Test func testPopToRoot() async throws {
        let sut = NavigationSwiftUI()
        sut.navigate(view: EmptyView())
        sut.navigate(view: EmptyView())
        sut.popToRoot()
        #expect(sut.routes.isEmpty)
        #expect(sut.items.isEmpty)
    }

    @Test func testPopToFlow() async throws {
        let sut = NavigationSwiftUI()
        sut.navigate(view: FlowViewTest())
        sut.register(route: Routes.home) { _ in
            FlowTest()
        }
        _ = try sut.flow(route: Routes.home)
        sut.navigate(view: EmptyView())
        sut.popToFlow()
        #expect(sut.routes.count == 1)
        #expect(sut.items.count == 2)
    }

    @Test func testPresentAndDismissView() async throws {
        let sut = NavigationSwiftUI()
        let mode: PresentMode = .sheet(EmptyView(), detents: [.fraction(0.5)])
        sut.present(mode)
        #expect(sut.routes.last == mode.routeString)
        sut.dismiss()
        #expect(sut.routes.last != mode.routeString)
    }

    @Test func testPresentViewWithRoute() async throws {
        let sut = NavigationSwiftUI()
        sut.register(route: Routes.home) { _ in
            EmptyView()
        }
        let mode: PresentMode = .fullScreenCover(Routes.home)
        sut.present(mode)
        #expect(sut.routes.last == mode.routeString)
    }

    @Test func testPresentAlert() async throws {
        let sut = NavigationSwiftUI()
        let mode: PresentMode = .alert(title: "Title", message: "Message")
        sut.present(mode)
        #expect(sut.routes.last == nil)
        #expect(sut.presentMode != nil)
    }

    @Test func testPresentConfirmationDialog() async throws {
        let sut = NavigationSwiftUI()
        let mode: PresentMode = .confirmationDialog(title: "Title", actions: [])
        sut.present(mode)
        #expect(sut.routes.last == nil)
        #expect(sut.presentMode != nil)
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

        sut.navigate(routeString: ".")
        sut.pop()
        sut.present(.fullScreenCover(Text("fullScreenCover")))
        sut.dismiss()
        sut.popToRoot()

        cancellable.cancel()

        #expect(result.navigate && result.present && result.pop && result.popToRoot && result.dismiss)
    }

    @Test func testRoutableWithParameter() throws {
        let sut = NavigationSwiftUI()
        sut.register(route: Routes.profile) { model in
            FlowViewTest(model: model)
        }
        #expect(sut.items.contains(Routes.profile.out.routeString))

        try sut.navigate(route: Routes.profile(InOutTest(text: "Ok")))
        let item = sut.items.getValue(for: Routes.profile.out.routeString) as? FlowViewTest
        #expect(item?.model.text == "Ok")
    }
}

final class InOutTest: InOutProtocol {
    let text: String

    init(text: String = "") {
        self.text = text
    }
}

@FlowCases
fileprivate enum Routes: Routable {
    case home
    case profile(InOutTest)
}

@FlowView(InOutTest.self)
struct FlowViewTest: FlowViewProtocol, View {
    var body: some View {
        EmptyView()
    }
}

@Flow(InOutEmpty.self, route: Routes.profile(InOutTest()))
fileprivate final class FlowTest: FlowProtocol {
    let node = FlowViewTest.node
}
