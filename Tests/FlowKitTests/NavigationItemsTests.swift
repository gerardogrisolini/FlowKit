//
//  NavigationItemsTests.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 26/11/24.
//

import SwiftUI
import Testing
@testable import FlowKit

struct NavigationItemsTests {
    
    /// Mock class conforming to `InOutProtocol` for testing purposes.
    struct MockInOut: InOutProtocol {
        let input: String
        var output: String?
    }
    
    let navigationItems = NavigationItems()

    /// Tests adding a new navigation item and checking for its existence.
    @Test func testAddAndContains() throws {
        navigationItems.setValue(for: "testKey") { param in
            return "TestValue"
        }
        
        let containsKey = navigationItems.contains("testKey")
        #expect(containsKey, "NavigationItems should contain 'testKey' after adding it.")
    }
    
    /// Tests retrieving the correct value for a key using `getValue`.
    @Test func testGetValue() async throws {
        navigationItems.setValue(for: "testKey") { param in
            return "TestValue"
        }
        
        let value = await navigationItems.getValue(for: "testKey")
        #expect(value as? String == "TestValue", "Value for 'testKey' should be 'TestValue'.")
    }
    
    /// Tests setting and retrieving parameters for a navigation item.
    @Test func testSetAndGetParam() throws {
        let mockParam = MockInOut(input: "inputValue", output: nil)
        
        navigationItems.setValue(for: "testKey") { param in
            guard let mock = param as? MockInOut else { return "Error" }
            return "Received \(mock.input)"
        }
        
        let paramSet = navigationItems.setParam(for: "testKey", param: mockParam)
        #expect(paramSet, "Parameter should be set successfully for 'testKey'.")
        
        let param = navigationItems.getParam(for: "testKey")
        #expect((param as? MockInOut)?.input == "inputValue", "Retrieved parameter input should match the set value.")
    }
    
    /// Tests removing a navigation item.
    @Test func testRemove() throws {
        navigationItems.setValue(for: "testKey") { param in
            EmptyView()
        }
        
        navigationItems.remove("testKey")
        
        let containsKey = navigationItems.contains("testKey")
        #expect(!containsKey, "NavigationItems should not contain 'testKey' after removal.")
    }
    
    /// Tests the `isEmpty` property.
    @Test func testIsEmpty() throws {
        #expect(navigationItems.isEmpty, "NavigationItems should initially be empty.")

        navigationItems.setValue(for: "testKey") { param in
            EmptyView()
        }
        
        #expect(!navigationItems.isEmpty, "NavigationItems should not be empty after adding an item.")
    }
    
    /// Tests the `count` property.
    @Test func testCount() throws {
        #expect(navigationItems.count == 0, "Count should be 0 initially.")
        
        navigationItems.setValue(for: "testKey1") { param in
            EmptyView()
        }
        
        navigationItems.setValue(for: "testKey2") { param in
            EmptyView()
        }
        
        #expect(navigationItems.count == 2, "Count should be 2 after adding two items.")
    }
}
