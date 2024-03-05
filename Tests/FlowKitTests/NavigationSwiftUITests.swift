import XCTest
import SwiftUI
@testable import FlowKit

final class NavigationSwiftUITests: XCTestCase {

    var sut: NavigationSwiftUI!

    override func setUp() {
        super.setUp()

        sut = NavigationSwiftUI()
    }

    override func tearDown() {
        super.tearDown()

        sut = nil
    }

    func testRegisterAndNavigateToRoute() throws {
        sut.register(route: Routes.home) {
            EmptyView()
        }
        XCTAssert(sut.items[Routes.home.rawValue]?() is EmptyView)

        try sut.navigate(route: Routes.home)
        XCTAssertEqual(sut.routes.last, Routes.home.rawValue)
    }

    func testNavigateToView() throws {
        let view = EmptyView()
        sut.navigate(view: view)
        XCTAssertEqual(sut.routes.last, view.routeString)
    }

    func testPop() throws {
        let view = EmptyView()
        sut.navigate(view: view)
        sut.pop()
        XCTAssertNotEqual(sut.routes.last, view.routeString)
        XCTAssertFalse(sut.items[view.routeString]?() is EmptyView)
    }

    func testPopToRoot() throws {
        sut.navigate(view: EmptyView())
        sut.navigate(view: EmptyView())
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
        sut.navigate(view: EmptyView())
        sut.popToFlow()
        XCTAssertTrue(sut.routes.count == 1)
        XCTAssertTrue(sut.items.count == 2)
    }

    func testPresentAndDismissView() throws {
        let view = EmptyView()
        sut.present(view: EmptyView())
        XCTAssertTrue(sut.items[view.routeString]?() is EmptyView)

        sut.dismiss()
        XCTAssertFalse(sut.items[view.routeString]?() is EmptyView)
        XCTAssertNotEqual(sut.routes.last, view.routeString)
    }

    func testActionSink() throws {
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
        sut.present(routeString: ".")
        sut.dismiss()
        sut.popToRoot()

        cancellable.cancel()

        XCTAssertTrue(result.navigate && result.present && result.pop && result.popToRoot && result.dismiss)
    }
}

extension EmptyView: Navigable, Presentable { }

fileprivate enum Routes: String, Routable {
    case home
    case profile
    case settings
}

fileprivate struct EmptyFlowView: FlowViewProtocol, View {
    enum Out: FlowOutProtocol {
        case empty
    }
    let model: InOutEmpty
    init(model: InOutEmpty = InOutEmpty()) {
        self.model = model
    }

    var body: some View {
        EmptyView()
    }
}

fileprivate class EmptyFlow: FlowProtocol {
    static let route: Routes = .settings
    var model = InOutEmpty()
    let node = EmptyFlowView.node
    required init() { }
}

