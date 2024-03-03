#  FlowKit: Test

Test the flow and page events.

```swift
final class ExampleTests: XCTestCase {
    func testExampleFlow() async throws {
        try await ExampleFlow().test()
    }

    func testUpdateOnPage2View() async throws {
        var sut = Page2View()
        sut.exampleService = ExampleServiceMock()
        let time = sut.model.time
        try await Task.sleep(nanoseconds: 1000000000)
        try await sut.test(event: .update(Date()))
        XCTAssertNotEqual(time, sut.model.time)
    }
}

class ExampleServiceMock: ExampleServiceProtocol {
    var date = Date()
    func getUserInfo() async throws -> UserInfoModel {
        UserInfoModel(id: 1, isAdmin: true, date: date)
    }

    func updateUserInfo(date: Date) async throws {
        self.date = date
    }
}
```
