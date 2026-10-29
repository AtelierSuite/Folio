import XCTest

final class WorkWeekSettingsTests: XCTestCase {
    @MainActor
    func testExcludedCalendarIsHiddenFromTheWorkingWeek() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Calendar.ViewMode", "workWeek", "-FolioSkipOnboarding"]
        app.launch()
        try XCTSkipUnless(app.staticTexts["Lunch with Aiko"].waitForExistence(timeout: 10), "Seed sample data first")

        app.tabBars.buttons.element(boundBy: 2).tap()
        app.buttons["WorkWeekLink"].tap()
        let thursday = app.switches.matching(identifier: "WorkWeek.Day.5").firstMatch
        XCTAssertTrue(thursday.waitForExistence(timeout: 5))
        attachScreenshot(named: "WorkWeekSettings")

        let sampleToggle = app.switches.matching(identifier: "WorkWeek.Calendar.Folio Samples").firstMatch
        sampleToggle.swipeUpIfNeeded(in: app)
        setToggle(sampleToggle, isOn: false)
        attachScreenshot(named: "WorkWeekSettingsCalendars")
        app.tabBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["Lunch with Aiko"].waitForNonExistence(timeout: 5))

        app.tabBars.buttons.element(boundBy: 2).tap()
        sampleToggle.swipeUpIfNeeded(in: app)
        setToggle(sampleToggle, isOn: true)
        app.tabBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["Lunch with Aiko"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func setToggle(_ toggle: XCUIElement, isOn: Bool) {
        let expectedValue = isOn ? "1" : "0"
        let hasExpectedValue = NSPredicate(format: "value == %@", expectedValue)
        for _ in 0..<3 where toggle.value as? String != expectedValue {
            toggle.switches.firstMatch.tap()
            _ = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: hasExpectedValue, object: toggle)], timeout: 2)
        }
        XCTAssertEqual(toggle.value as? String, expectedValue)
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

private extension XCUIElement {
    @MainActor
    func swipeUpIfNeeded(in app: XCUIApplication) {
        var attempts = 0
        while !isHittable && attempts < 5 {
            app.swipeUp()
            attempts += 1
        }
    }
}
