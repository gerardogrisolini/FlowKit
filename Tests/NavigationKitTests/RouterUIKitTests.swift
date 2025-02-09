//
//  RouterUIKitTests.swift
//  NavigationKitTests
//
//  Created by Gerardo Grisolini on 21/11/24.
//

#if canImport(UIKit)
import Testing
import UIKit
@testable import NavigationKit

@MainActor
final class RouterUIKitTests {

    var sut: RouterUIKit!

    init() async throws {
        sut = RouterUIKit()
        sut.navigationController = UINavigationController()
    }

    deinit {
        sut = nil
    }

    @Test func testRegisterAndNavigateToRoute() async throws {
        sut.register(route: Routes.home, for: UIViewController.init)
        #expect(sut.items.getValue(for: Routes.home.routeString) is UIViewController)

        try sut.navigate(route: Routes.home)
        #expect(sut.routes.last == Routes.home.routeString)
    }

    @Test func testNavigateToView() async throws {
        let view = UIViewController()
        sut.navigate(view: view)
        #expect(sut.routes.last == view.routeString)
    }

    @Test func testPop() async throws {
        let view = UIViewController()
        sut.navigate(view: view)
        sut.pop()
        #expect(sut.routes.last != view.routeString)
        #expect(sut.items.getValue(for: view.routeString) == nil)
    }

    @Test func testPopToRoot() async throws {
        sut.navigate(view: UIViewController())
        sut.navigate(view: UIViewController())
        sut.popToRoot()
        #expect(sut.routes.isEmpty)
        #expect(sut.items.isEmpty)
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

    @Test func testRoutableWithParameter() throws {
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
    case settings
    case test(InOutTest)
}
#endif
