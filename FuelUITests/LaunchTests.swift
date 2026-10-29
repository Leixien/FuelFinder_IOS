import XCTest

final class LaunchTests: XCTestCase {
    /// Fixture data, fixed position in Naples and a frozen clock (see AppEnvironment.uiTest).
    @MainActor
    private func launch() -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        return app
    }

    @MainActor
    func testLaunchShowsCheapestCard() {
        let app = launch()
        XCTAssertTrue(app.element("home.cheapestCard").waitForExistence(timeout: 10))
    }

    /// Going back to the system theme re-presents the results sheet; Info must still close and the card come back.
    @MainActor
    func testSystemThemeResetLeavesTheAppUsable() {
        let app = launch()
        XCTAssertTrue(app.element("home.cheapestCard").waitForExistence(timeout: 10))
        app.element("home.themeToggle").tap()
        app.element("home.info").tap()
        let systemButton = app.buttons["info.systemTheme"]
        XCTAssertTrue(systemButton.waitForExistence(timeout: 5))
        systemButton.tap()

        XCTAssertTrue(systemButton.waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.element("home.cheapestCard").waitForExistence(timeout: 5))
    }
}

private extension XCUIApplication {
    func element(_ identifier: String) -> XCUIElement {
        descendants(matching: .any)[identifier].firstMatch
    }
}
