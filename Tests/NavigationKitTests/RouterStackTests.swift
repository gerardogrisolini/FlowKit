//
//  RouterStackTests.swift
//  NavigationKitTests
//
//  Created by Gerardo Grisolini on 21/11/24.
//

import Testing
import SwiftUI
import Dispatch
@testable import NavigationKit

@MainActor
struct RouterStackTests {
    private func waitUntil(
        timeoutNanoseconds: UInt64 = 1_000_000_000,
        pollNanoseconds: UInt64 = 1_000_000,
        _ condition: @autoclosure @escaping () -> Bool
    ) async {
        let start = DispatchTime.now().uptimeNanoseconds
        while !condition() && (DispatchTime.now().uptimeNanoseconds - start) < timeoutNanoseconds {
            try? await Task.sleep(nanoseconds: pollNanoseconds)
        }
    }

    @Test func testInitialization() {
        let stack = RouterStack(router: RouterMock())
        #expect(stack.routes.isEmpty)
        #expect(stack.presentMode == nil)
    }

    @Test func testNavigate() async throws {
        let view = EmptyView()
        let stack = RouterStack(router: RouterMock())
        stack.router.navigate(view: view)
        await waitUntil(stack.routes.last == view.routeString)
        #expect(stack.routes.count == 1)
        #expect(stack.routes.last == view.routeString)
    }

    @Test func testPop() async throws {
        let stack = RouterStack(router: RouterMock())
        stack.router.navigate(view: EmptyView())
        await waitUntil(!stack.routes.isEmpty)
        stack.router.pop()
        await waitUntil(stack.routes.isEmpty)
        #expect(stack.routes.isEmpty)
    }

    @Test func testPopToRoot() async throws {
        let stack = RouterStack(router: RouterMock())
        stack.router.navigate(view: Text(""))
        await waitUntil(stack.routes.count == 1)
        stack.router.navigate(view: EmptyView())
        await waitUntil(stack.routes.count == 2)
        stack.router.popToRoot()
        await waitUntil(stack.routes.isEmpty)
        #expect(stack.routes.isEmpty)
    }

    @Test func testPresentModal() async throws {
        let presentMode: PresentMode = .sheet(EmptyView())
        let stack = RouterStack(router: RouterMock())
        stack.router.present(presentMode)
        await waitUntil(stack.presentMode == presentMode)
        #expect(stack.presentMode == presentMode)
        #expect(stack.routes.isEmpty)
        #expect(stack.isSheet)
    }

    @Test func testDismissModal() async throws {
        let presentMode: PresentMode = .fullScreenCover(EmptyView())
        let stack = RouterStack(router: RouterMock())
        stack.router.present(presentMode)
        await waitUntil(stack.isFullScreenCover)
        #expect(stack.isFullScreenCover)
        stack.router.dismiss()
        await waitUntil(stack.presentMode == nil)
        #expect(stack.presentMode == nil)
    }
}
