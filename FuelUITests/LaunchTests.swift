import XCTest

final class LaunchTests: XCTestCase {
    @MainActor
    func testLaunchShowsCheapestCard() {
        let app = XCUIApplication()
        // Fixture data, fixed position in Naples and a frozen clock (see AppEnvironment.uiTest).
        app.launchArguments = ["-uiTesting"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["home.cheapestCard"].firstMatch.waitForExistence(timeout: 10))
    }
}
