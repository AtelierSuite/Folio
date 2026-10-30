import XCTest

final class NotificationStyleTests: XCTestCase {
    @MainActor
    private var springboard: XCUIApplication {
        XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    @MainActor
    func testTimeSensitiveCalendarDeliversATimeSensitiveAlert() throws {
        let app = launchIntoAlertStyles()
        chooseStyle("Time Sensitive", in: app)
        attachScreenshot(named: "AlertStylesTimeSensitive")

        let banner = springboard.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "Folio Test Alert")).firstMatch
        XCTAssertTrue(banner.waitForExistence(timeout: 150))
        attachScreenshot(named: "DeliveredTimeSensitiveAlert")
        chooseStyle("Time Sensitive", in: app)
    }

    @MainActor
    func testAlarmCalendarSchedulesAnAlarmOrFallsBackToTimeSensitive() throws {
        let app = launchIntoAlertStyles()
        chooseStyle("Alarm", in: app)
        allowSystemPromptIfAsked()
        let isDenied = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Folio isn’t allowed"))
            .firstMatch.waitForExistence(timeout: 5)
        attachScreenshot(named: "AlertStylesAlarm")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        let alarmCount = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label BEGINSWITH %@", "Alarms Scheduled")).firstMatch
        XCTAssertTrue(alarmCount.waitForExistence(timeout: 10))
        let scheduledCount = app.descendants(matching: .any)["NotificationsScheduledCount"]
        let expected = NSPredicate { _, _ in
            let alarms = Self.count(in: alarmCount) > 0
            let notifications = Self.count(in: scheduledCount) > 0
            return isDenied ? notifications : alarms
        }
        expectation(for: expected, evaluatedWith: nil)
        waitForExpectations(timeout: 10)
        attachScreenshot(named: isDenied ? "AlarmDeniedFallbackStatus" : "AlarmScheduledStatus")

        let alert = springboard.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "Folio Test Alert")).firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 150))
        attachScreenshot(named: isDenied ? "DeliveredFallbackAlert" : "FiredAlarm")
        app.activate()
        app.buttons["NotificationStylesLink"].tap()
        chooseStyle("Time Sensitive", in: app)
    }

    @MainActor
    private static func count(in element: XCUIElement) -> Int {
        if let value = element.value as? String, let count = Int(value) {
            return count
        }
        return Int(element.label.split(separator: " ").last ?? "") ?? 0
    }

    @MainActor
    func testEditorsOfferAnAlertStyleOverride() throws {
        let app = launchIntoAlertStyles()
        app.tabBars.buttons.element(boundBy: 0).tap()
        for item in ["New Event", "New Reminder"] {
            app.buttons["Add"].firstMatch.tap()
            app.buttons[item].tap()
            let row = app.buttons["NotificationStyleOverride"]
            for _ in 0..<5 where !row.isHittable {
                app.swipeUp()
            }
            XCTAssertTrue(row.waitForExistence(timeout: 5))
            row.tap()
            XCTAssertTrue(app.buttons["Default (Time Sensitive)"].waitForExistence(timeout: 5))
            app.buttons["Standard"].tap()
            attachScreenshot(named: "\(item) Alert Style")
            app.buttons["Cancel"].firstMatch.tap()
            let discard = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Discard")).firstMatch
            if discard.waitForExistence(timeout: 2) {
                discard.tap()
            }
        }
    }

    @MainActor
    private func launchIntoAlertStyles() -> XCUIApplication {
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
            allowSystemPromptIfAsked()
        }
        app.buttons["NotificationStylesLink"].tap()
        return app
    }

    @MainActor
    private func chooseStyle(_ title: String, in app: XCUIApplication) {
        let row = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "NotificationStyle.")).firstMatch
        guard row.waitForExistence(timeout: 5) else {
            attachScreenshot(named: "MissingRow")
            XCTFail(app.debugDescription)
            return
        }
        row.tap()
        let option = app.buttons[title]
        XCTAssertTrue(option.waitForExistence(timeout: 5))
        option.tap()
    }

    @MainActor
    private func allowSystemPromptIfAsked() {
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
