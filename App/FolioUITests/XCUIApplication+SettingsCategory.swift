import XCTest

extension XCUIApplication {
    @MainActor
    func openSettingsCategory(_ category: String) {
        let link = buttons["SettingsCategory.\(category)"]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        link.tap()
    }
}
