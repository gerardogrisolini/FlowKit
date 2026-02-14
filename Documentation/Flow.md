#  FlowKit: Flow

Implementation of a flow.

```swift
import FlowKit

/// Your flow must implement FlowProtocol.
/// The model variable is mandatory, it is an object that implements InOutProtocol
/// and is the return value you have at the closure or completion of the flow.
/// The route variable is mandatory and must be an enum that implements Routable.
@Flow(InOutModel.self, route: ExampleRoutes.example(InOutModel()))
public final class ExampleFlow: FlowProtocol {

    /// The node variable is mandatory and represents the root node of your flow.
    /// You can use the builder to construct your flow declaratively.
    /// For each defined navigation event, you must reconnect the corresponding node or flow.
    /// This way the builder will automatically build your flow.
    public let node = Page1View.node {
        $0.page2 ~ Page2View.node {
            $0.page3 ~ Page3View.node
            $0.page4 ~ Page4View.node {
                $0.page5 ~ Page5View.node
            }
            $0.uikit ~ Routes.exampleUIKit
        }
        $0.page5 ~ Page5View.node
    }
}
```

### Implementation of routes of the flows
```swift
@FlowCases
public enum Routes: Routable {
    case home
    case example(InOutModel)
    case exampleLite
    case exampleUIKit
}
```

### Implementation of behavior in a flow.
```swift
extension ExampleFlow {

    /// Out type function that is executed between the navigation of one node and another.
    private func runOut(_ out: any FlowOutProtocol) async throws -> Results {
        do {
            let num = Int.random(in: 0..<5)
            switch num {
            case 0: throw FlowError.generic
            case 1:
                throw FlowError.invalidModel(String(describing: out))
            default: break
            }
        } catch FlowError.generic {
            return .node(Page5View.node, InOutModel())
        } catch {
            throw error
        }

        return .model(InOutModel())
    }

    /// Event type function that is executed in the flow instead of on the page.
    private func runEvent(_ event: any FlowEventProtocol) async throws -> any InOutProtocol {
        InOutModel()
    }
}
```
