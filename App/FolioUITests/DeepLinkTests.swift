import XCTest

final class DeepLinkTests: XCTestCase {
    @MainActor
    func testComposerLinksOpenTheRightEditor() throws {
        let app = launchApp()
        try open("folio://new/event", in: app)
        XCTAssertTrue(app.navigationBars["New Event"].waitForExistence(timeout: 10))
        app.swipeDown(velocity: .fast)
        app.terminate()

        let relaunched = launchApp()
        try open("folio://new/reminder", in: relaunched)
        XCTAssertTrue(relaunched.navigationBars["New Reminder"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testNewNoteLinkCreatesANote() throws {
        let app = launchApp()
        try open("folio://new/note", in: app)
        XCTAssertTrue(app.tabBars.buttons["Notes"].wait(for: \.isSelected, toEqual: true, timeout: 10))
        XCTAssertTrue(app.textViews.firstMatch.waitForExistence(timeout: 10))
    }

    @MainActor
    func testDayLinkShowsThatDay() throws {
        let app = launchApp()
        try open("folio://day/2026-03-14", in: app)
        XCTAssertTrue(app.navigationBars["March 2026"].waitForExistence(timeout: 10))
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-FolioSkipOnboarding"]
        app.launch()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 10))
        return app
    }

    @MainActor
    private func open(_ string: String, in app: XCUIApplication) throws {
        app.open(try XCTUnwrap(URL(string: string)))
    }
}
