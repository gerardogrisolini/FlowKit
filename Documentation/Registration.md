#  FlowKit: Registration

Register the navigation and services your app requires.

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
