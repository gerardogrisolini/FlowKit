#  FlowKit: Navigation

Management of navigation within a module or between modules.

### Inject the navigation

```swift
@Injected var navigation: NavigationProtocol
```

### Navigation to a page without going through a flow, involves two cases

#### If the page is visible from the module
```swift
navigation.navigate(view: Page1View())
```

#### If the page is not visible from the module
```swift
/// You must first register it by associating it with a route
sut.register(route: Routes.example) { model in
    Page1View(model: model)
}

/// And then you can navigate to it by passing the route
try navigation.navigate(route: Routes.example(InOutModel(text: "Test"))
```

### Navigation to a flow

```swift
/// You need to first retrieve the flow through the route
let flow = try navigation.flow(route: Routes.example)

/// And then start it using the start function
let result = try await flow.start()

/// you can shorten it
try await navigation.flow(route: Routes.example).start()
```

### Presenting a page involves two cases

#### If the page is visible from the module
```swift
navigation.present(.sheet(ErrorView(), detents: [.medium]))
```

#### If the page is not visible from the module
```swift
/// You must first register it by associating it with a route
navigation.register(route: Routes.example) {
    ErrorView()
}

/// And then you can present it by passing the route
try navigation.present(.fullScreenCover(Routes.example))
```

### Alerts and condirmation dialogs
```swift
navigation.present(.alert(title: "Exception", message: "Parameter cannot be null"))

let actions: [AlertAction] = [
    .init(title: "Hide", style: .default, handler: {}),
    .init(title: "Delete logical", style: .cancel, handler: {}),
    .init(title: "Delete physical", style: .destructive, handler: {})
]
navigation.present(.confirmationDialog(title: "Confirmation", actions: actions))
```

### Pop and dismiss

```swift
/// Back navigation
navigation.pop()

/// Back navigation to the root
navigation.popToRoot()

/// Back navigation to the point where the flow started
navigation.popToFlow()

/// Dismissal of a presented page
navigation.dismiss()
```
