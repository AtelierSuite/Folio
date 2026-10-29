import XCTest

final class ReminderCheckboxTests: XCTestCase {
    @MainActor
    func testCheckingOffReminderOnDayTimelineTogglesIt() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Calendar.ViewMode", "day", "-FolioSkipOnboarding"]
        app.launch()

        let checkbox = app.buttons["ReminderCheckbox.Renew passport"]
        try XCTSkipUnless(checkbox.waitForExistence(timeout: 10), "Seed sample data first")
        XCTAssertFalse(checkbox.isSelected)

        checkbox.tap()
        XCTAssertTrue(checkbox.wait(for: \.isSelected, toEqual: true, timeout: 5))
        attachScreenshot(named: "ReminderChecked")

        checkbox.tap()
        XCTAssertTrue(checkbox.wait(for: \.isSelected, toEqual: false, timeout: 5))
    }

    @MainActor
    func testInboxListsUndatedRemindersAndReachesListVisibility() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Calendar.ViewMode", "day", "-FolioSkipOnboarding"]
        app.launch()

        let inboxButton = app.buttons["ReminderInboxButton"]
        XCTAssertTrue(inboxButton.waitForExistence(timeout: 10))
        inboxButton.tap()
        let undated = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Plan weekend trip")).firstMatch
        try XCTSkipUnless(undated.waitForExistence(timeout: 5), "Seed sample data first")
        attachScreenshot(named: "ReminderInbox")

        app.buttons["ReminderInboxListsLink"].tap()
        XCTAssertTrue(app.switches.matching(identifier: "CalendarVisibility.Folio Samples").firstMatch
            .waitForExistence(timeout: 5))
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
