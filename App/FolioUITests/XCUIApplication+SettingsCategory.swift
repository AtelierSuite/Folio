import XCTest

extension XCUIApplication {
    @MainActor
    func openSettingsCategory(_ category: String) {
        let link = buttons["SettingsCategory.\(category)"]
        if !link.waitForExistence(timeout: 3) {
            for _ in 0..<4 where !link.exists {
                swipeUp()
            }
            for _ in 0..<8 where !link.exists {
                swipeDown()
            }
        }
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
