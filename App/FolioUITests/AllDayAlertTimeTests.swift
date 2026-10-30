import XCTest

final class AllDayAlertTimeTests: XCTestCase {
    @MainActor
    private var springboard: XCUIApplication {
        XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    @MainActor
    func testCalendarsOfferAnAllDayAlertTimeDefaultingToEight() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-SeedTestAlertEvent", "-FolioSkipOnboarding", "-AppleLanguages", "(en)"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        app.tabBars.buttons.element(boundBy: 2).tap()
        app.buttons["NotificationSettingsLink"].tap()
        let toggle = app.switches["NotificationsEnabledToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        if toggle.value as? String != "1" {
            toggle.switches.firstMatch.tap()
            let allow = springboard.alerts.buttons.element(boundBy: 1)
            if allow.waitForExistence(timeout: 5) {
                allow.tap()
            }
        }
        attachScreenshot(named: "NotificationSettings")
        app.buttons["AllDayAlertTimesLink"].tap()
        let row = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "AllDayAlertTime.")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        let defaultTime = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@ OR value CONTAINS %@", "8:00", "8:00")).firstMatch
        XCTAssertTrue(defaultTime.waitForExistence(timeout: 5))
        attachScreenshot(named: "AllDayAlertTimes")
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
