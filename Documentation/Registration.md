#  FlowKit: Registration

Register the navigation and services your app requires.

#### SwiftUI
```swift
import FlowKit

@main
struct FlowApp: App {
    init() {
        /// Inizialize and register the navigation
        FlowKit.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                /// Join page to the flow
                .join(flow: ContentFlow())
        }
    }
}
```

#### UIKit
```swift
import FlowKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let navigationController = UINavigationController()
        FlowKit.initialize(navigationType: .uiKit(navigationController: navigationController))

        navigationController.setViewControllers([ViewController()], animated: false)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
```

### Speaking of Annotations, to resolving services in your modules using the property wrapper.
```swift
@Injected(\.navigation) var navigation
```

### If you want to use only navigation without flows.
```swift
import NavigationKit

@main
struct FlowApp: App {
    init() {
        /// Inizialize and register the navigation
        NavigationKit.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                /// Join page to the navigation
                .navigationKit()
        }
    }
}
```
