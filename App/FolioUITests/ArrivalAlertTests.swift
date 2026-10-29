import XCTest

final class ArrivalAlertTests: XCTestCase {
    // Simulators can't monitor regions, so the arrival is fed in with -SimulateArrival after the switches are on.
    @MainActor
    func testArrivingAtAnEventLocationDeliversAnAlert() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FolioSkipOnboarding"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        app.tabBars.buttons.element(boundBy: 2).tap()
        app.buttons["NotificationSettingsLink"].tap()
        turnOn(app.switches["NotificationsEnabledToggle"], allowing: ["Allow", "許可"])
        turnOn(app.switches["ArrivalAlertsToggle"], allowing: ["Allow While Using App", "アプリの使用中は許可"])
        attachScreenshot(named: "ArrivalSettings")

        app.terminate()
        app.launchArguments += ["-SeedArrivalTestEvent", "-SimulateArrival"]
        app.launch()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let banner = springboard.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "Folio Arrival Test")).firstMatch
        XCTAssertTrue(banner.waitForExistence(timeout: 30))
        attachScreenshot(named: "ArrivalAlert")
    }

    @MainActor
    func testNewEventNeedsALocationForArrivalAlerts() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FolioSkipOnboarding"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        app.buttons.matching(NSPredicate(format: "label IN %@", ["Add", "追加"])).firstMatch.tap()
        app.buttons.matching(NSPredicate(format: "label IN %@", ["New Event", "新規イベント"])).firstMatch.tap()
        let toggle = app.switches["NotifyOnArrivalToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertFalse(toggle.isEnabled)
        attachScreenshot(named: "EventEditorArrivalToggle")
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
