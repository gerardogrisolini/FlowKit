# FlowKit

A Swift framework for modular navigation with type-safe, composable flows.

## Requirements

- Swift 6.2+
- iOS 16+
- visionOS 1+
- macOS 14+
- Mac Catalyst 14+

## Why FlowKit

- Type-safe flow graph built with enums and macros.
- Modular by design: flows/pages can live in separate packages.
- Unified navigation API for SwiftUI and UIKit.
- Test-friendly architecture for routing and events.

## Quick Start

Add FlowKit with SwiftPM:

```swift
dependencies: [
    .package(url: "https://github.com/gerardogrisolini/FlowKit.git", from: "3.0.0")
]
```

Initialize routing and apply navigation to your root view:

```swift
import FlowKit
import SwiftUI

@main
struct DemoApp: App {
    init() {
        FlowKit.initialize(withFlowRouting: true)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .navigationKit()
        }
    }
}
```

## Documentation

Start here:

1. [Installation](./Documentation/Installation.md)
2. [Registration](./Documentation/Registration.md)
3. [Page](./Documentation/Page.md)
4. [Flow](./Documentation/Flow.md)
5. [Navigation](./Documentation/Navigation.md)
6. [Test](./Documentation/Test.md)

## Platform Notes

- SwiftUI navigation uses `NavigationStack`.
- UIKit router APIs are excluded on visionOS.

## Additional Resources

* [API Documentation](https://gerardogrisolini.github.io/FlowKit/documentation/flowkit)


## Demo Application

I've made my [Example](https://github.com/gerardogrisolini/FlowKit-Example) repository public.


## Author

FlowKit was designed, implemented, documented, and maintained by [Gerardo Grisolini](https://www.linkedin.com/in/gerardo-grisolini-b5900248/), a Senior iOS engineer.
* Email: [gerardo.grisolini@gmail.com](mailto:gerardo.grisolini@gmail.com)


## License

FlowKit is available under the MIT license. See the LICENSE file for more info.
