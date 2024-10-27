#  FlowKit: Test

Test the flow and page events.

```swift
final class ExampleTests {

    @Test func testExampleFlow() async throws {
        try await ExampleFlow().test()
    }

    @Test func testUpdateOnPage2View() async throws {
        let sut = await Page2View(model: InOutModel(), service: ExampleServiceMock())
        let time1 = await sut.model.time
        try await Task.sleep(nanoseconds: 1000000000)
        try await sut.test(event: .update(Date()))
        let time2 = await sut.model.time
        #expect(time1 != time2)
    }
}

fileprivate final class ExampleServiceMock: ExampleServiceProtocol {
    @MainActor var date = Date()
    func getUserInfo() async throws -> UserInfoModel {
        await UserInfoModel(id: 1, isAdmin: true, date: date)
    }

    @MainActor
    func updateUserInfo(date: Date) async throws {
        self.date = date
    }
}
```
