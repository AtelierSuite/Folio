import XCTest

extension XCUIApplication {
    @MainActor
    @discardableResult
    func continuePermissionPrompt(_ kind: String, allowing allowLabels: [String] = ["Allow", "許可"]) -> Bool {
        let button = buttons["PermissionPrompt.\(kind).Continue"]
        guard button.waitForExistence(timeout: 3) else { return false }
        button.tap()
        let allow = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.buttons
            .matching(NSPredicate(format: "label IN %@", allowLabels)).firstMatch
        if allow.waitForExistence(timeout: 5) {
            allow.tap()
        }
        _ = button.waitForNonExistence(timeout: 5)
        return true
    }

    @MainActor
    func allowNotificationsIfPrompted() {
        guard continuePermissionPrompt("notifications") else { return }
        let isOn = NSPredicate(format: "value == '1'")
        let turnedOn = XCTNSPredicateExpectation(predicate: isOn, object: switches["NotificationsEnabledToggle"])
        _ = XCTWaiter().wait(for: [turnedOn], timeout: 5)
    }

    @MainActor
    func turnOnNotifications() {
        allowNotificationsIfPrompted()
        let toggle = switches["NotificationsEnabledToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        if toggle.value as? String != "1" {
            toggle.switches.firstMatch.tap()
        }
    }
}
