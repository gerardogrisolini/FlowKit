#  FlowKit: Registration

Register the navigation and services your app requires.

#### SwiftUI
```swift
@main
struct FlowApp: App {
    init() {
        /// Initialize and register the navigation
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

#### UIKit (not available on visionOS)
```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let rootView = ContentView()
        let viewController = UIHostingController(rootView: rootView)
        let navigationController = UINavigationController(rootViewController: viewController)
        FlowKit.initialize(navigationType: .uiKit(navigationController: navigationController))
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    
        Task {
            do {
                try await ContentFlow().start(parent: rootView, navigate: false)
            } catch {
                print(error)
            }
        }
    }
}
```

### Resolve services in your modules using the property wrapper
```swift
@Injected(\.router) var router
```

### If you want to use only navigation without flows.
```swift
import NavigationKit

@main
struct FlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                /// Join page to the navigation
                .navigationKit()
        }
    }
}
```
