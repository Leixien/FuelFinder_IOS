import XCTest

final class LaunchTests: XCTestCase {
    @MainActor
    func testAppLaunchesToRootView() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["root.placeholder"].firstMatch.waitForExistence(timeout: 5))
    }
}
