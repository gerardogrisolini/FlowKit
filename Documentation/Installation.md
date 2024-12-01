#  FlowKit: Installation

FlowKit primarily uses SwiftPM as its build tool, so we recommend using that as well. If you want to depend on FlowKit in your own project, it's as simple as adding a dependencies clause to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/gerardogrisolini/FlowKit.git", from: "2.2.0")
]
```
