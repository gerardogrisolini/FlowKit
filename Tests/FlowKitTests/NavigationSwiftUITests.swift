import Testing
import SwiftUI
@testable import FlowKit

@MainActor
final class NavigationSwiftUITests {

    @Test func testRegisterAndNavigateToRoute() async throws {
        let sut = NavigationSwiftUI()
        await sut.register(route: Routes.home) { _ in
            EmptyView()
        }
        #expect(await sut.items.getValue(for: Routes.home.routeString) is EmptyView)

        try await sut.navigate(route: Routes.home)
        #expect(sut.routes.last == Routes.home.routeString)
    }

    @Test func testNavigateToView() async throws {
        let sut = NavigationSwiftUI()
        let view = EmptyView()
        await sut.navigate(view: view)
        #expect(sut.routes.last == view.routeString)
    }

    @Test func testPop() async throws {
        let sut = NavigationSwiftUI()
        let view = EmptyView()
        await sut.navigate(view: view)
        await sut.pop()
        #expect(sut.routes.last != view.routeString)
        #expect(await sut.items.getValue(for: view.routeString) == nil)
    }

    @Test func testPopToRoot() async throws {
        let sut = NavigationSwiftUI()
        await sut.navigate(view: EmptyView())
        await sut.navigate(view: EmptyView())
        await sut.popToRoot()
        #expect(sut.routes.isEmpty)
        #expect(await sut.items.isEmpty)
    }

    @Test func testPopToFlow() async throws {
        let sut = NavigationSwiftUI()
        await sut.navigate(view: EmptyFlowView())
        await sut.register(route: Routes.home) { _ in
            EmptyFlow()
        }
        _ = try await sut.flow(route: Routes.home)
        await sut.navigate(view: EmptyView())
        await sut.popToFlow()
        #expect(sut.routes.count == 1)
        #expect(await sut.items.count == 2)
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
        await sut.register(route: Routes.home) { _ in
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
        await sut.pop()
        sut.present(.fullScreenCover(Text("fullScreenCover")))
        sut.dismiss()
        await sut.popToRoot()

        cancellable.cancel()

        #expect(result.navigate && result.present && result.pop && result.popToRoot && result.dismiss)
    }

    @Test func testRoutableWithParameter() async throws {
        let sut = NavigationSwiftUI()
        await sut.register(route: Routes.profile) { model in
            await EmptyFlowView(model: model)
        }
        #expect(await sut.items.contains(Routes.profile.out.routeString))

        try await sut.navigate(route: Routes.profile(InOutModel(text: "Ok")))
        let item = await sut.items.getValue(for: Routes.profile.out.routeString) as? EmptyFlowView
        #expect(item?.model.text == "Ok")
    }
}

fileprivate struct InOutModel: InOutProtocol {
    let text: String

    init(text: String = "") {
        self.text = text
    }
}

@FlowCases
fileprivate enum Routes: Routable {
    case home
    case profile(InOutModel)
}

@FlowView(InOutModel.self)
fileprivate struct EmptyFlowView: FlowViewProtocol, View {
    var body: some View {
        EmptyView()
    }
}

@Flow(InOutEmpty.self, route: Routes.profile(InOutModel()))
fileprivate final class EmptyFlow: FlowProtocol {
    let node = EmptyFlowView.node
}
