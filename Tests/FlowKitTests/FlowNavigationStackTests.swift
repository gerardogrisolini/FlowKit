//
//  Test.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 21/11/24.
//

import Testing
import SwiftUI
@testable import FlowKit

@MainActor
struct FlowNavigationStackV1Tests {

    @Test func testInitialization() {
        let stack = FlowNavigationStackV1(navigation: NavigationMock())
        #expect(stack.route == nil)
        #expect(stack.presentMode == nil)
    }

    @Test func testNavigate() async throws {
        let view = EmptyView()
        let stack = FlowNavigationStackV1(navigation: NavigationMock())
        stack.navigation.navigate(view: view)
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.route == view.routeString)
    }

    @Test func testPop() async throws {
        let stack = FlowNavigationStackV1(navigation: NavigationMock())
        stack.navigation.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 150000000)
        stack.navigation.pop()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.route == nil)
    }

    @Test func testPopToRoot() async throws {
        let stack = FlowNavigationStackV1(navigation: NavigationMock())
        stack.navigation.navigate(view: Text(""))
        try await Task.sleep(nanoseconds: 150000000)
        stack.navigation.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 15000000)
        stack.navigation.popToRoot()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.route == nil)
    }

    @Test func testPresentModal() async throws {
        let presentMode: PresentMode = .sheet(EmptyView())
        let stack = FlowNavigationStackV1(navigation: NavigationMock())
        stack.navigation.present(presentMode)
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.presentMode == presentMode)
        #expect(stack.route == nil)
        #expect(stack.isSheet)
    }

    @Test func testDismissModal() async throws {
        let presentMode: PresentMode = .fullScreenCover(EmptyView())
        let stack = FlowNavigationStackV1(navigation: NavigationMock())
        stack.navigation.present(presentMode)
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.isFullScreenCover)
        stack.navigation.dismiss()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.presentMode == nil)
    }
}

@MainActor
struct FlowNavigationStackV2Tests {

    @available(iOS 16.0, *)
    @Test func testInitialization() {
        let stack = FlowNavigationStackV2(navigation: NavigationMock())
        #expect(stack.routes.isEmpty)
        #expect(stack.presentMode == nil)
    }

    @available(iOS 16.0, *)
    @Test func testNavigate() async throws {
        let view = EmptyView()
        let stack = FlowNavigationStackV2(navigation: NavigationMock())
        stack.navigation.navigate(view: view)
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.routes.count == 1)
        #expect(stack.routes.last == view.routeString)
    }

    @available(iOS 16.0, *)
    @Test func testPop() async throws {
        let stack = FlowNavigationStackV2(navigation: NavigationMock())
        stack.navigation.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 150000000)
        stack.navigation.pop()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.routes.isEmpty)
    }

    @available(iOS 16.0, *)
    @Test func testPopToRoot() async throws {
        let stack = FlowNavigationStackV2(navigation: NavigationMock())
        stack.navigation.navigate(view: Text(""))
        try await Task.sleep(nanoseconds: 15000000)
        stack.navigation.navigate(view: EmptyView())
        try await Task.sleep(nanoseconds: 15000000)
        stack.navigation.popToRoot()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.routes.isEmpty)
    }

    @available(iOS 16.0, *)
    @Test func testPresentModal() async throws {
        let presentMode: PresentMode = .sheet(EmptyView())
        let stack = FlowNavigationStackV2(navigation: NavigationMock())
        stack.navigation.present(presentMode)
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.presentMode == presentMode)
        #expect(stack.routes.isEmpty)
        #expect(stack.isSheet)
    }

    @available(iOS 16.0, *)
    @Test func testDismissModal() async throws {
        let presentMode: PresentMode = .fullScreenCover(EmptyView())
        let stack = FlowNavigationStackV2(navigation: NavigationMock())
        stack.navigation.present(presentMode)
        try await Task.sleep(nanoseconds: 150000000)
        #expect(stack.isFullScreenCover)
        stack.navigation.dismiss()
        try await Task.sleep(nanoseconds: 15000000)
        #expect(stack.presentMode == nil)
    }
}
