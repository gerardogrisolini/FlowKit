//
//  FlowProtocol+Extension.swift
//  FlowKit
//
//  Created by Gerardo Grisolini on 13/02/25.
//

public extension FlowProtocol {

    func start(parent: (any FlowViewProtocol)? = nil, navigate: Bool = true) async throws {
        try await Coordinator(flow: self, parent: parent).start(navigate: navigate)
    }

    func runEvent(_ event: any FlowEventProtocol) async throws -> any InOutProtocol {
        event.associated.value ?? InOutEmpty()
    }

    func runOut(_ out: any FlowOutProtocol) async throws -> Results {
        .model(out.associated.value ?? InOutEmpty())
    }

    /// Tests the specified route to ensure its associated value and the node's model match.
    /// - Throws: A `FlowError.invalidModel` error if the class name of the route's associated value
    /// does not match the class name of the flow's node model.
    /// Additionally, propagates any error thrown by the `testNode(node:)` method.
    func test() async throws {
        // Extract the class name from the associated value of the route, defaulting to "InOutEmpty" if nil.
        var m = Self.route.associated.value?.className ?? "InOutEmpty"

        // Remove any namespace or module prefix from the class name, leaving only the base class name.
        if let index = m.lastIndex(of: ".") {
            m = String(m.suffix(from: m.index(after: index)))
        }

        // Ensure the extracted class name matches the class name of the node's model.
        guard m == String(describing: node.model) else {
            throw FlowError.invalidModel(m) // Throw an error if there is a mismatch.
        }

        // Test the node structure to ensure that all events and joins are properly mapped and validated.
        try testNode(node: node)
    }

    /// Tests the given node to ensure that all its events and joins are correctly mapped and validated.
    /// - Parameter node: An instance conforming to `Nodable`, representing the node to be tested.
    /// - Throws: A `FlowError.partialMapping` if the number of events does not match the joins,
    /// or if any associated value or node validation fails during testing.
    private func testNode(node: any Nodable) throws {
        switch node {
        case let n as any CoordinatorNodeProtocol:
            // Ensure the number of events matches the number of joins
            guard n.eventsCount == n.joins.count else {
                throw FlowError.partialMapping(String(describing: n.view))
            }

            // Retrieve the class name of the node's model
            var className = "\(n.model)".className

            // Iterate over each join to validate the node and its associated values
            for join in n.joins {
                if let value = join.event.associated.value {
                    className = "\(value)".id
                }
                if let node = join.node as? any CoordinatorNodeProtocol {
                    // Validate the node's class name and recursively test its child nodes
                    try node.validate(className: className)
                    try testNode(node: node)
                }
            }
        default:
            break // No action for non-CoordinatorNodeProtocol conforming nodes
        }
    }
}
