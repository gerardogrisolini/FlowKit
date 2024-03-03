#  FlowKit: Page


Implementation of a page for a flow.

#### SwiftUI
```swift
import SwiftUI
import FlowKit

// Your page must implement FlowViewProtocol.
struct Page1View: FlowViewProtocol, View {

    // If you need to navigate to other pages you need to define an Out enum.
    enum Out: FlowOutProtocol {
        case page2, page3
    }

    // If you need to execute an event within your page you need to define an enum Event.
    enum Event: FlowEventProtocol {
        case update(Date)
    }

    // The model variable is mandatory, it is an object that implements InOutProtocol.
    // Represents the data that the page expects as input.
    @State var model: InOutModel

    var body: some View {
        VStack(spacing: 8) {
            Text(model.time)
                .font(.headline)

            Button(ExampleKeys.update) {
                // Raise an event to update the model date.
                event(.update(Date()))
            }

            Button(ExampleKeys.page2) {
                // Raise an event to navigate to page 2.
                out(.page2)
            }

            Button(ExampleKeys.page3) {
                // Raise an event to navigate to page 3.
                out(.page3)
            }
        }
        .navigationBarTitle(ExampleKeys.page1, largeMode: true)
    }

    // If you have defined an enum for events,
    // you need to implement this method to handle them.
    func onEventChanged(_ event: Event, _ data: (any InOutProtocol)?) async {
        switch event {
        case .update(let date):
            model.time = date.description
        }
    }
}
```

#### UIKit
```swift
import UIKit
import FlowKit

final class Page1View: UIViewController, FlowViewProtocol {

    enum Out: FlowOutProtocol {
        case page2
    }

    let model: InOutModel

    required init(model: InOutModel) {
        self.model = model
        super.init(nibName: "Page1View", bundle: .module)
        title = ExampleKeys.page1.localized
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func buttonTapped(_ sender: Any) {
        out(.page2)
    }
}
```
