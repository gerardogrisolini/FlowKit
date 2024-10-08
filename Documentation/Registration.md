#  FlowKit: Registration

Register the navigation and services your app requires.

#### SwiftUI
```swift
@main
struct FlowApp: App {
    init() {
        // Inizialize and register the navigation
        FlowKit.initialize()
        
        // Register the other services you need
        FlowKit.register(scope: .application) {
            FlowNetwork() as FlowNetworkProtocol
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // 
                .join(flow: ContentFlow())
        }
    }
}
```

#### UIKit
```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let navigationController = UINavigationController()
        FlowKit.initialize(navigationType: .uiKit(navigationController: navigationController))
        FlowKit.register(scope: .application) {
            FlowNetwork() as FlowNetworkProtocol
        }

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
@Injected var navigation: NavigationProtocol
@LazyInjected var flowNetwork: FlowNetworkProtocol
@WeakLazyInjected var service: AnotherLazyService?
```
