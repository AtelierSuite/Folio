import XCTest

final class CalendarCreationMenuTests: XCTestCase {
    @MainActor
    func testDoubleTappingAnEmptyHourOffersAnEventThere() throws {
        let app = launch(mode: "day")
        let card = app.buttons["Lunch with Aiko"].firstMatch
        try XCTSkipUnless(card.waitForExistence(timeout: 15), "Grant calendar access to seed sample data first")
        // The hour labels sit left of the cards, so this lands on the empty grid beside them.
        card.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0))
            .withOffset(CGVector(dx: 0, dy: -70))
            .doubleTap()
        let newEvent = menuItem("CreationMenu.Event", in: app)
        XCTAssertTrue(newEvent.waitForExistence(timeout: 5))
        XCTAssertTrue(menuItem("CreationMenu.Reminder", in: app).exists)
        attachScreenshot(named: "timeline-creation-menu", app: app)
        newEvent.tap()
        XCTAssertTrue(app.navigationBars["New Event"].waitForExistence(timeout: 10))
        attachScreenshot(named: "timeline-new-event", app: app)
    }

    @MainActor
    func testDoubleTappingAMonthDayOffersAReminderOnIt() throws {
        let app = launch(mode: "month")
        let cell = try XCTUnwrap(app.onScreenMonthCell(for: XCUIApplication.day(-2), timeout: 15))
        cell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9)).doubleTap()
        let newReminder = menuItem("CreationMenu.Reminder", in: app)
        XCTAssertTrue(newReminder.waitForExistence(timeout: 5))
        attachScreenshot(named: "month-creation-menu", app: app)
        newReminder.tap()
        XCTAssertTrue(app.navigationBars["New Reminder"].waitForExistence(timeout: 10))
        attachScreenshot(named: "month-new-reminder", app: app)
    }

    @MainActor
    func testTappingAMonthDayStillSelectsIt() throws {
        let app = launch(mode: "month")
        let cell = try XCTUnwrap(app.onScreenMonthCell(for: XCUIApplication.day(-2), timeout: 15))
        cell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9)).tap()
        XCTAssertTrue(cell.wait(for: \.isSelected, toEqual: true, timeout: 5))
        XCTAssertFalse(menuItem("CreationMenu.Event", in: app).exists)
    }

    @MainActor
    private func menuItem(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    @MainActor
    private func attachScreenshot(named name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func launch(mode: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-Calendar.ViewMode", mode,
            "-FolioSkipOnboarding", "-SeedSampleCalendarData"
        ]
        app.launch()
        return app
    }
}
