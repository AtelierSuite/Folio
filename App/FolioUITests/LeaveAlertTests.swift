import XCTest

final class LeaveAlertTests: XCTestCase {
    // The seeded event is at Apple Park in 30 minutes, so from San Francisco it's already time to leave.
    @MainActor
    func testTimeToLeaveDeliversAnAlert() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FolioSkipOnboarding"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        app.tabBars.buttons.element(boundBy: 2).tap()
        app.buttons["NotificationSettingsLink"].tap()
        turnOn(app.switches["NotificationsEnabledToggle"], allowing: ["Allow", "許可"])
        turnOn(app.switches["LeaveAlertsToggle"], allowing: ["Allow While Using App", "アプリの使用中は許可"])
        XCTAssertTrue(app.buttons["TravelTransportPicker"].waitForExistence(timeout: 5)
            || app.otherElements["TravelTransportPicker"].exists)
        attachScreenshot(named: "LeaveSettings")

        app.terminate()
        app.launchArguments += ["-SeedLeaveTestEvent"]
        app.launch()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let banner = springboard.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "Folio Arrival Test")).firstMatch
        XCTAssertTrue(banner.waitForExistence(timeout: 60))
        attachScreenshot(named: "LeaveAlert")
    }

    @MainActor
    func testNewEventNeedsALocationForTimeToLeave() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FolioSkipOnboarding"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        app.buttons.matching(NSPredicate(format: "label IN %@", ["Add", "追加"])).firstMatch.tap()
        app.buttons.matching(NSPredicate(format: "label IN %@", ["New Event", "新規イベント"])).firstMatch.tap()
        let toggle = app.switches["TimeToLeaveToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertFalse(toggle.isEnabled)
        attachScreenshot(named: "EventEditorLeaveToggle")
    }

    @MainActor
    private func turnOn(_ toggle: XCUIElement, allowing allowLabels: [String]) {
        if !toggle.waitForExistence(timeout: 3) {
            XCUIApplication().swipeUp()
        }
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        if toggle.value as? String == "1" {
            toggle.switches.firstMatch.tap()
        }
        toggle.switches.firstMatch.tap()
        let button = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.buttons
            .matching(NSPredicate(format: "label IN %@", allowLabels)).firstMatch
        if button.waitForExistence(timeout: 5) {
            button.tap()
        }
        let isOn = NSPredicate(format: "value == '1'")
        expectation(for: isOn, evaluatedWith: toggle)
        waitForExpectations(timeout: 5)
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
