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
struct RouterStackV1Tests {
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
        let stack = RouterStackV1(router: RouterMock())
        #expect(stack.route == nil)
        #expect(stack.presentMode == nil)
    }

    @Test func testNavigate() async throws {
        let view = EmptyView()
        let stack = RouterStackV1(router: RouterMock())
        stack.router.navigate(view: view)
        await waitUntil(stack.route == view.routeString)
        #expect(stack.route == view.routeString)
    }

    @Test func testPop() async throws {
        let stack = RouterStackV1(router: RouterMock())
        stack.router.navigate(view: EmptyView())
        await waitUntil(stack.route != nil)
        stack.router.pop()
        await waitUntil(stack.route == nil)
        #expect(stack.route == nil)
    }

    @Test func testPopToRoot() async throws {
        let stack = RouterStackV1(router: RouterMock())
        stack.router.navigate(view: Text(""))
        await waitUntil(stack.route != nil)
        stack.router.navigate(view: EmptyView())
        await waitUntil(stack.route != nil)
        stack.router.popToRoot()
        await waitUntil(stack.route == nil)
        #expect(stack.route == nil)
    }

    @Test func testPresentModal() async throws {
        let presentMode: PresentMode = .sheet(EmptyView())
        let stack = RouterStackV1(router: RouterMock())
        stack.router.present(presentMode)
        await waitUntil(stack.presentMode == presentMode)
        #expect(stack.presentMode == presentMode)
        #expect(stack.route == nil)
        #expect(stack.isSheet)
    }

    @Test func testDismissModal() async throws {
        let presentMode: PresentMode = .fullScreenCover(EmptyView())
        let stack = RouterStackV1(router: RouterMock())
        stack.router.present(presentMode)
        await waitUntil(stack.isFullScreenCover)
        #expect(stack.isFullScreenCover)
        stack.router.dismiss()
        await waitUntil(stack.presentMode == nil)
        #expect(stack.presentMode == nil)
    }
}

@MainActor
struct RouterStackV2Tests {
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

    @available(iOS 16.0, *)
    @Test func testInitialization() {
        let stack = RouterStackV2(router: RouterMock())
        #expect(stack.routes.isEmpty)
        #expect(stack.presentMode == nil)
    }

    @available(iOS 16.0, *)
    @Test func testNavigate() async throws {
        let view = EmptyView()
        let stack = RouterStackV2(router: RouterMock())
        stack.router.navigate(view: view)
        await waitUntil(stack.routes.last == view.routeString)
        #expect(stack.routes.count == 1)
        #expect(stack.routes.last == view.routeString)
    }

    @available(iOS 16.0, *)
    @Test func testPop() async throws {
        let stack = RouterStackV2(router: RouterMock())
        stack.router.navigate(view: EmptyView())
        await waitUntil(!stack.routes.isEmpty)
        stack.router.pop()
        await waitUntil(stack.routes.isEmpty)
        #expect(stack.routes.isEmpty)
    }

    @available(iOS 16.0, *)
    @Test func testPopToRoot() async throws {
        let stack = RouterStackV2(router: RouterMock())
        stack.router.navigate(view: Text(""))
        await waitUntil(stack.routes.count == 1)
        stack.router.navigate(view: EmptyView())
        await waitUntil(stack.routes.count == 2)
        stack.router.popToRoot()
        await waitUntil(stack.routes.isEmpty)
        #expect(stack.routes.isEmpty)
    }

    @available(iOS 16.0, *)
    @Test func testPresentModal() async throws {
        let presentMode: PresentMode = .sheet(EmptyView())
        let stack = RouterStackV2(router: RouterMock())
        stack.router.present(presentMode)
        await waitUntil(stack.presentMode == presentMode)
        #expect(stack.presentMode == presentMode)
        #expect(stack.routes.isEmpty)
        #expect(stack.isSheet)
    }

    @available(iOS 16.0, *)
    @Test func testDismissModal() async throws {
        let presentMode: PresentMode = .fullScreenCover(EmptyView())
        let stack = RouterStackV2(router: RouterMock())
        stack.router.present(presentMode)
        await waitUntil(stack.isFullScreenCover)
        #expect(stack.isFullScreenCover)
        stack.router.dismiss()
        await waitUntil(stack.presentMode == nil)
        #expect(stack.presentMode == nil)
    }
}
