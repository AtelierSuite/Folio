import XCTest

final class NotificationSchedulingTests: XCTestCase {
    @MainActor
    func testEnablingNotificationsSchedulesAndDeliversAnAlert() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-SeedTestAlertEvent"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        app.tabBars.buttons.element(boundBy: 2).tap()
        app.buttons["NotificationSettingsLink"].tap()
        let toggle = app.switches["NotificationsEnabledToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        if toggle.value as? String != "1" {
            toggle.switches.firstMatch.tap()
            allowNotificationsIfAsked()
        }

        let scheduledCount = app.descendants(matching: .any)["NotificationsScheduledCount"]
        XCTAssertTrue(scheduledCount.waitForExistence(timeout: 10))
        let hasScheduled = NSPredicate { _, _ in !scheduledCount.label.hasSuffix(" 0") && scheduledCount.label != "0" }
        expectation(for: hasScheduled, evaluatedWith: nil)
        waitForExpectations(timeout: 10)
        attachScreenshot(named: "NotificationSettings")

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let banner = springboard.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "Folio Test Alert")).firstMatch
        XCTAssertTrue(banner.waitForExistence(timeout: 120))
        attachScreenshot(named: "DeliveredAlert")
    }

    @MainActor
    private func allowNotificationsIfAsked() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.alerts.buttons.element(boundBy: 1)
        if allow.waitForExistence(timeout: 5) {
            allow.tap()
        }
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
