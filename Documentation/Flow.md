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
public enum Routes: Routable  {
    case home
    case example(InOutModel)
    case exampleLite
    case exampleUIKit
}
```

### Implementation of onStart in a flow
```swift
extension ExampleFlow {

    /// The onStart function is optional and is called when the flow starts.
    /// You can use it to carry out checks before the flow starts, to manage settings or more.
    public func onStart(model: some InOutProtocol) async throws -> any InOutProtocol {
        let networkService = await NetworkService()
        let user = try await networkService.getUserInfo()
        guard user.isAdmin else {
            throw FlowError.generic
        }
        return model
    }
}
```
