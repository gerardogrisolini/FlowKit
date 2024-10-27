#  FlowKit: Behavior

Implementation of behavior in a flow.

```swift
extension ExampleFlow {

    // The behavior variable is optional and customizes the behavior of your flow.
    // You can use the builder to build your behavior declaratively.
    public var behavior: FlowBehavior {
        FlowBehavior {
            // With Localizables you can replace localized keys 
            // with the ones you want to use in your flow.
            Localizables {
                ExampleKeys.page1 ~ ExampleKeys.page5
                ExampleKeys.page2 ~ ExampleKeys.page4
                ExampleKeys.page4 ~ ExampleKeys.page2
                ExampleKeys.page5 ~ ExampleKeys.page1
            }
            // With Outs you can set the functions to be performed 
            // between the navigation of one node and another.
            Outs {
                Page2View.Out.page3(InOutModel()) ~ runOut
            }
            // With Events you can set the functions to be performed 
            // in the flow instead of on the page.
            Events {
                Page2View.Event.update(Date()) ~ runEvent
            }
        }
    }

    // Out type function that is executed between the navigation of one node and another.
    private func runOut(_ out: any InOutProtocol) async throws -> Results {
        do {
            let num = Int.random(in: 0..<3)
            switch num {
            case 0: throw FlowError.generic
            case 1: throw FlowError.invalidModel(String(describing: model))
            default: break
            }
        } catch FlowError.generic {
            return .node(Page5View.node, model)
        } catch {
            throw error
        }

        return .model(model)
    }

    // Event type function that is executed in the flow instead of on the page.
    private func runEvent(_ event: any FlowEventProtocol) async throws -> any InOutProtocol {
        InOutEmpty()
    }
}
```
