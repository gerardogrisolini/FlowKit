//
//  RouterSwiftUITests.swift
//  NavigationKitTests
//
//  Created by Gerardo Grisolini on 21/11/24.
//

import Testing
import SwiftUI
@testable import NavigationKit

@MainActor
final class RouterSwiftUITests {

    @Test func testRegisterAndNavigateToRoute() async throws {
        let sut = RouterSwiftUI()
        sut.register(route: Routes.home) {
            EmptyView()
        }
        #expect(sut.items.getValue(for: Routes.home.routeString) is EmptyView)

        try sut.navigate(route: Routes.home)
        #expect(sut.routes.last == Routes.home.routeString)
    }

    @Test func testNavigateToView() async throws {
        let sut = RouterSwiftUI()
        let view = EmptyView()
        sut.navigate(view: view)
        #expect(sut.routes.last == view.routeString)
    }

    @Test func testPop() async throws {
        let sut = RouterSwiftUI()
        let view = EmptyView()
        sut.navigate(view: view)
        sut.pop()
        #expect(sut.routes.last != view.routeString)
        #expect(sut.items.getValue(for: view.routeString) == nil)
    }

    @Test func testPopToRoot() async throws {
        let sut = RouterSwiftUI()
        sut.navigate(view: EmptyView())
        sut.navigate(view: EmptyView())
        sut.popToRoot()
        #expect(sut.routes.isEmpty)
        #expect(sut.items.isEmpty)
    }

    @Test func testPresentAndDismissView() async throws {
        let sut = RouterSwiftUI()
        let mode: PresentMode = .sheet(EmptyView(), detents: [.fraction(0.5)])
        sut.present(mode)
        #expect(sut.routes.last == mode.routeString)
        sut.dismiss()
        #expect(sut.routes.last != mode.routeString)
    }

    @Test func testPresentViewWithRoute() async throws {
        let sut = RouterSwiftUI()
        sut.register(route: Routes.home) {
            EmptyView()
        }
        let mode: PresentMode = .fullScreenCover(Routes.home)
        sut.present(mode)
        #expect(sut.routes.last == mode.routeString)
    }

    @Test func testPresentAlert() async throws {
        let sut = RouterSwiftUI()
        let mode: PresentMode = .alert(title: "Title", message: "Message")
        sut.present(mode)
        #expect(sut.routes.last == nil)
        #expect(sut.presentMode != nil)
    }

    @Test func testPresentConfirmationDialog() async throws {
        let sut = RouterSwiftUI()
        let mode: PresentMode = .confirmationDialog(title: "Title", actions: [])
        sut.present(mode)
        #expect(sut.routes.last == nil)
        #expect(sut.presentMode != nil)
    }

    @Test func testActionSink() async throws {
        let sut = RouterSwiftUI()
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
        let sut = RouterSwiftUI()
        sut.register(route: Routes.test) { model in
            FlowViewTest(model: model)
        }
        #expect(sut.items.contains(Routes.test.out.routeString))

        try sut.navigate(route: Routes.test(InOutTest(text: "Ok")))
        let item = sut.items.getValue(for: Routes.test.out.routeString) as? FlowViewTest
        #expect(item?.model.text == "Ok")
    }
}

@FlowCases
fileprivate enum Routes: Routable {
    case home
    case test(InOutTest)
}

final class InOutTest: InOutProtocol {
    let text: String

    init(text: String = "") {
        self.text = text
    }
}

struct FlowViewTest: View {
    let model: InOutTest
    var body: some View {
        EmptyView()
    }
}
