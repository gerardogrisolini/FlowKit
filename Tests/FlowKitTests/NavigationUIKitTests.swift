import XCTest
import UIKit
@testable import FlowKit

final class NavigationUIKitTests: XCTestCase {

    var sut: NavigationUIKit!

    override func setUp() {
        super.setUp()

        sut = NavigationUIKit()
        sut.navigationController = UINavigationController()
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
    }

    func testRegisterAndNavigateToRoute() throws {
        sut.register(route: Routes.home) {
            UIViewController()
        }
        XCTAssert(sut.items[Routes.home.rawValue]?() is UIViewController)

        try sut.navigate(route: Routes.home)
        XCTAssertEqual(sut.routes.last, Routes.home.rawValue)
    }

    func testNavigateToView() throws {
        let view = UIViewController()
        sut.navigate(view: view)
        XCTAssertEqual(sut.routes.last, view.routeString)
    }

    func testPop() throws {
        let view = UIViewController()
        sut.navigate(view: view)
        sut.pop()
        XCTAssertNotEqual(sut.routes.last, view.routeString)
        XCTAssertFalse(sut.items[view.routeString]?() is UIViewController)
    }

    func testPopToRoot() throws {
        sut.navigate(view: UIViewController())
        sut.navigate(view: UIViewController())
        sut.popToRoot()
        XCTAssertTrue(sut.routes.isEmpty)
        XCTAssertTrue(sut.items.isEmpty)
    }

    func testPopToFlow() throws {
        sut.navigate(view: EmptyFlowView())
        sut.register(route: Routes.settings) {
            EmptyFlow()
        }
        _ = try sut.flow(route: Routes.settings)
        sut.navigate(view: UIViewController())
        sut.popToFlow()
        XCTAssertTrue(sut.routes.count == 1)
        XCTAssertTrue(sut.items.count == 2)
    }

    func testPresentAndDismissView() throws {
        let view = UIViewController()
        sut.present(view: UIViewController())
        XCTAssertTrue(sut.items[view.routeString]?() is UIViewController)

        sut.dismiss()
        XCTAssertFalse(sut.items[view.routeString]?() is UIViewController)
        XCTAssertNotEqual(sut.routes.last, view.routeString)
    }
}

extension UIViewController: Navigable, Presentable { }

fileprivate enum Routes: String, Routable {
    case home
    case profile
    case settings
}

fileprivate class EmptyFlow: FlowProtocol {
    static let route: Routes = .settings
    var model = InOutEmpty()
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
