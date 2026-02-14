//
//  FlowViewTests.swift
//  FlowKitTests
//
//  Created by Gerardo Grisolini on 27/10/24.
//

import SwiftUI
import Testing
@testable import FlowKit

struct FlowViewTests {

    @Test func testAllEvents() async throws {
        var eventsCount: Int = 0
        let sut = await ParentView()

        Task { @MainActor in
            sut.back()
            sut.out(.out1)
            sut.out(.out2)
            sut.event(.event1)
            sut.event(.event2)
            sut.navigate(EmptyView())
            sut.present(.sheet(EmptyView()))
            sut.commit(InOutEmpty(), toRoot: false)
        }

        for try await event in sut.events {
            switch event {
            case .back:
                eventsCount += 1
            case .navigate(let view):
                eventsCount += 1
                #expect(view is EmptyView)
            case .present(let mode):
                eventsCount += 1
                guard case .sheet(let view, _) = mode else { continue }
                #expect(view is EmptyView)
            case .next(let event):
                eventsCount += 1
                #expect([ParentView.Out.out1.id, ParentView.Out.out2.id].contains(event.id))
            case .event(let event):
                eventsCount += 1
                #expect([ParentView.Event.event1.id, ParentView.Event.event2.id].contains(event.id))
            case .commit(_, toRoot: let toRoot):
                eventsCount += 1
                #expect(!toRoot)
                sut.events.finish()
            }
        }

        #expect(eventsCount == 8)
    }

    @Test func testGoodMappingWidget() async throws {
        try await WidgetView().test(parent: ParentView())
    }

    @Test func testBadMappingWidget() async throws {
        do {
            try await WidgetView().test(parent: BadParentView())
            #expect(Bool(false), "Expected partial mapping error")
        } catch {
            // Expected failure path.
        }
    }
}

fileprivate struct WidgetView: FlowWidgetProtocol, View {
    @Environment(\.parent) var parent

    enum Out: FlowOutProtocol {
        case out1, out2
    }
    enum Event: FlowEventProtocol {
        case event1, event2
    }
    let model = InOutEmpty()

    var body: some View {
        Text("WidgetView")
    }
}

@FlowView(InOutEmpty.self)
private struct ParentView: FlowViewProtocol, View {
    enum Out: FlowOutProtocol {
        case out1, out2
    }
    enum Event: FlowEventProtocol {
        case event1, event2
    }

    var body: some View {
        Text("ParentView")
    }
}

@FlowView(InOutEmpty.self)
private struct BadParentView: FlowViewProtocol, View {
    enum Out: FlowOutProtocol {
        case out1
    }
    enum Event: FlowEventProtocol {
        case event1
    }

    var body: some View {
        Text("BadParentView")
    }
}
