import XCTest

final class CalendarVisibilityTests: XCTestCase {
    @MainActor
    func testHidingCalendarRemovesItsEventsFromAgenda() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Calendar.ViewMode", "list"]
        app.launch()
        try XCTSkipUnless(app.staticTexts["Lunch with Aiko"].waitForExistence(timeout: 10), "Seed sample data first")

        app.tabBars.buttons.element(boundBy: 2).tap()
        app.buttons["CalendarVisibilityLink"].tap()
        let sampleToggle = app.switches.matching(identifier: "CalendarVisibility.Folio Samples").firstMatch
        XCTAssertTrue(sampleToggle.waitForExistence(timeout: 5))
        attachScreenshot(named: "CalendarVisibility")

        sampleToggle.switches.firstMatch.tap()
        app.tabBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["Lunch with Aiko"].waitForNonExistence(timeout: 5))
        let reminderRow = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Buy groceries")).firstMatch
        XCTAssertTrue(reminderRow.exists)

        app.tabBars.buttons.element(boundBy: 2).tap()
        sampleToggle.switches.firstMatch.tap()
        app.tabBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["Lunch with Aiko"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
