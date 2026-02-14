#  FlowKit: Navigation

Management of navigation within a module or between modules.

### Inject the navigation

```swift
@Injected(\.router) var router
```

### Navigation to a page without going through a flow, involves two cases

#### If the page is visible from the module
```swift
router.navigate(view: Page1View())
```

#### If the page is not visible from the module
```swift
/// You must first register it by associating it with a route
router.register(route: Routes.example) { model in
    Page1View(model: model)
}

/// And then you can navigate to it by passing the route
try router.navigate(route: Routes.example(InOutModel(text: "Test")))
```

### Navigation to a flow

```swift
/// You need to first retrieve the flow through the route
let flow = try router.flow(route: Routes.example)

/// And then start it using the start function
let result = try await flow.start()

/// you can shorten it
try await router.flow(route: Routes.example).start()
```

### Presenting a page involves two cases

#### If the page is visible from the module
```swift
router.present(.sheet(ErrorView(), detents: [.medium]))
```

#### If the page is not visible from the module
```swift
/// You must first register it by associating it with a route
router.register(route: Routes.example) {
    ErrorView()
}

/// And then you can present it by passing the route
router.present(.fullScreenCover(Routes.example))
```

### Alert
```swift
router.present(.alert(title: "Exception", message: "Parameter cannot be null"))
```
        
### Confirmation dialog
```swift
let actions: [AlertAction] = [
    .init(title: "Hide", style: .default, handler: {}),
    .init(title: "Delete logical", style: .cancel, handler: {}),
    .init(title: "Delete physical", style: .destructive, handler: {})
]
router.present(.confirmationDialog(title: "Confirmation", actions: actions))
```

### Toast
```swift
router.present(.toast(message: "Exception", style: .error))
```

### Loader
```swift
router.present(.loader(style: .circle))
```

### Pop and dismiss

```swift
/// Back navigation
router.pop()

/// Back navigation to the root
router.popToRoot()

/// Back navigation to the point where the flow started
router.popToFlow()

/// Dismissal of a presented page
router.dismiss()
```
