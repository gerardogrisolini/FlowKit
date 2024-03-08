#  FlowKit: Registration

Register the navigation and services your app requires.

#### SwiftUI
```swift
@main
struct FlowApp: App, FlowKitApp {
    init() {
        // Register the navigation
        registerNavigationSwiftUI()
        
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

        let navigationController = UINavigationController()
        registerNavigationUIKit(navigationController: navigationController)
        register(scope: .application) {
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
