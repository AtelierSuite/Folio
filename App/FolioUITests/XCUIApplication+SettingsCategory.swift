import XCTest

extension XCUIApplication {
    @MainActor
    func openSettingsCategory(_ category: String) {
        let link = buttons["SettingsCategory.\(category)"]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        link.tap()
    }

    @MainActor
    func openFirstCalendarNotificationSettings() {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", "CalendarNotificationRow.")
        let row = buttons.matching(predicate).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10))
        row.tap()
    }
}
