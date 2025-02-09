//
//  RouterStackTests.swift
//  NavigationKitTests
//
//  Created by Gerardo Grisolini on 21/11/24.
//

import Testing
import SwiftUI
@testable import NavigationKit

@MainActor
struct RouterStackV1Tests {

    @Test func testInitialization() {
        let stack = RouterStackV1(router: RouterMock())
        #expect(stack.route == nil)
        #expect(stack.presentMode == nil)
    }

    @Test func testNavigate() async throws {
        let view = EmptyView()
        let stack = RouterStackV1(router: RouterMock())
        stack.router.navigate(view: view)
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.route == view.routeString)
    }

    @Test func testPop() async throws {
        let stack = RouterStackV1(router: RouterMock())
        stack.router.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 150000000)
        stack.router.pop()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.route == nil)
    }

    @Test func testPopToRoot() async throws {
        let stack = RouterStackV1(router: RouterMock())
        stack.router.navigate(view: Text(""))
        try await Task.sleep(nanoseconds: 150000000)
        stack.router.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 15000000)
        stack.router.popToRoot()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.route == nil)
    }

    @Test func testPresentModal() async throws {
        let presentMode: PresentMode = .sheet(EmptyView())
        let stack = RouterStackV1(router: RouterMock())
        stack.router.present(presentMode)
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.presentMode == presentMode)
        #expect(stack.route == nil)
        #expect(stack.isSheet)
    }

    @Test func testDismissModal() async throws {
        let presentMode: PresentMode = .fullScreenCover(EmptyView())
        let stack = RouterStackV1(router: RouterMock())
        stack.router.present(presentMode)
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.isFullScreenCover)
        stack.router.dismiss()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.presentMode == nil)
    }
}

@MainActor
struct RouterStackV2Tests {

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
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.routes.count == 1)
        #expect(stack.routes.last == view.routeString)
    }

    @available(iOS 16.0, *)
    @Test func testPop() async throws {
        let stack = RouterStackV2(router: RouterMock())
        stack.router.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 150000000)
        stack.router.pop()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.routes.isEmpty)
    }

    @available(iOS 16.0, *)
    @Test func testPopToRoot() async throws {
        let stack = RouterStackV2(router: RouterMock())
        stack.router.navigate(view: Text(""))
        try await Task.sleep(nanoseconds: 15000000)
        stack.router.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 15000000)
        stack.router.popToRoot()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.routes.isEmpty)
    }

    @available(iOS 16.0, *)
    @Test func testPresentModal() async throws {
        let presentMode: PresentMode = .sheet(EmptyView())
        let stack = RouterStackV2(router: RouterMock())
        stack.router.present(presentMode)
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.presentMode == presentMode)
        #expect(stack.routes.isEmpty)
        #expect(stack.isSheet)
    }

    @available(iOS 16.0, *)
    @Test func testDismissModal() async throws {
        let presentMode: PresentMode = .fullScreenCover(EmptyView())
        let stack = RouterStackV2(router: RouterMock())
        stack.router.present(presentMode)
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.isFullScreenCover)
        stack.router.dismiss()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.presentMode == nil)
    }
}
