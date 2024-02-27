# FlowKit

Framework for building modular applications with composable flows.


## Why FlowKit?

The goal of FlowKit is to provide an easy-to-use infrastructure for building modular and composable applications, allowing you to break code into independent packages and build navigation flows and functionality in a modular and flexible way.

### Main advantages of a modular architecture are:

1. **Modularity**: Splitting into independent packages allows you to create separate modules that perform specific functions, making code management and maintenance easier.
2. **Code reusability**: Independent packages allow you to easily reuse specific parts of your application in different contexts or projects.
3. **Simplify development**: Working on smaller packages simplifies development by allowing different teams to work in parallel on separate modules.
4. **Testability**: Splitting the application into independent packages facilitates the creation of specific tests for each module, improving the overall quality of the software.
5. **Scalability**: The modular structure promotes the scalability of the application, allowing you to add new features or modify existing parts more easily.
6. **Dependency management**: Independent packages allow you to more efficiently manage dependencies between the various parts of the application, reducing the risk of conflicts or errors.
7. **Agility in development**: The division into independent packages promotes an agile approach to development, allowing changes to be made more quickly and with fewer impacts on the rest of the application.
8. **Compile times**: Splitting into independent packages reduces compilation times, allowing you to work more efficiently and productively.

### Main advantages of FlowKit are:

1. **Navigation**: A system that allows you to navigate between modules that are not sold to each other, in a transparent and flexible way, using either UIkit or SwiftUI navigation.
2. **Graph**: Each flow has its own navigation graph connected to the others through an enum, thus creating a complete map of the possible navigations that is easily readable.
3. **Enum-based pattern**: Using an enum-based pattern makes the logic easier to understand and test.
4. **Reuse pages and flows**: Makes pages reusable in different flows, speeding up the development of a flow and limiting code duplication.


## Using FlowKit

### Installation

FlowKit primarily uses SwiftPM as its build tool, so we recommend using that as well. If you want to depend on FlowKit in your own project, it's as simple as adding a dependencies clause to your Package.swift:
```swift
dependencies: [
    .package(url: "https://github.com/gerardogrisolini/FlowKit.git", branch: "main")
]
```


### Register the navigation and services your app requires

#### SwiftUI
```swift
@main
struct FlowApp: App, FlowKitApp {
    init() {
        // Register the navigation
        register(navigation: NavigationSwiftUI())
        
        // Register the other services you need
        register(scope: .application) {
            FlowNetwork() as FlowNetworkProtocol
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .swiftUINavigation()
        }
    }
}
```

#### UIKit
```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FlowKitApp {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let view = UIViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = view
        window?.makeKeyAndVisible()

        let navigation = NavigationUIKit()
        navigation.navigationController = view.navigationController

        register(navigation: navigation)
        register(scope: .application) {
            FlowNetwork() as FlowNetworkProtocol
        }

        return true
    }
}
```

### Speaking of Annotations, to resolving services in your modules using the property wrapper.
```swift
@Injected var navigation: NavigationProtocol
@LazyInjected var flowNetwork: FlowNetworkProtocol
@WeakLazyInjected var service: AnotherLazyService?
```


### Implementation of a page

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


### Implementation of a flow
```swift
import FlowKit

// Your flow must implement FlowProtocol.
public final class ExampleFlow: FlowProtocol {

    // The route variable is mandatory and must be an enum that implements Routable.
    public static var route: ExampleRoutes = .example

    // The model variable is mandatory, it is an object that implements InOutProtocol 
    // and is the return value you have at the closure or completion of the flow.
    public var model = InOutModel()

    // The node variable is mandatory and represents the root node of your flow.
    // You can use the builder to construct your flow declaratively.
    // For each defined navigation event, you must reconnect 
    // the corresponding node or flow.
    // This way the builder will automatically build your flow.
    public let node = Page1View.node {
        $0.page2 ~ Page2View.node {
            $0.page3 ~ ExampleRoutes.exampleLite
            $0.page4 ~ Page4View.node {
                $0.page5 ~ Page5View.node
            }
        }
        $0.page5 ~ Page5View.node
    }

    public init() { }
}
```

### Implementation of onStart in a flow
```swift
extension ExampleFlow {

    // The onStart function is optional and is called when the flow starts.
    // You can use it to carry out checks before the flow starts,
    // to manage settings or more.
    public func onStart(model: some InOutProtocol) async throws -> any InOutProtocol {
        let exampleService: ExampleServiceProtocol = NetworkService()
        let user = try await exampleService.userInfo()
        guard user.isAdmin else {
            throw FlowError.generic
        }
        return model
    }
}
```

### Implementation of behavior in a flow
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
                Page2View.Out.page3 ~ runOut
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

## Test

### Test the flow and page events
```swift
final class ExampleTests: XCTestCase {
    func testExampleFlow() async throws {
        try await ExampleFlow().test()
    }

    func testUpdateOnPage2View() async throws {
        let sut = Page2View()
        let time = sut.model.time
        try await Task.sleep(nanoseconds: 1000000000)
        try await sut.test(event: .update(Date()))
        XCTAssertNotEqual(time, sut.model.time)
    }
}
```


## Demo Application

I've made my [Builder](https://github.com/gerardogrisolini/FlowKit-Example) repository public. It's a simple flow application that contains examples of...


## Author

Resolver was designed, implemented, documented, and maintained by [Gerardo Grisolini](https://www.linkedin.com/in/gerardo-grisolini-b5900248/), a Senior Lead iOS engineer.
* Email: [gerardo.grisolini@gmail.com](mailto:gerardo.grisolini@gmail.com)


## License

FlowKit is available under the MIT license. See the LICENSE file for more info.

