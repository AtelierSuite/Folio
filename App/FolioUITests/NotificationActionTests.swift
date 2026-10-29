import XCTest

final class NotificationActionTests: XCTestCase {
    @MainActor
    private var springboard: XCUIApplication {
        XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testMarkDoneCompletesTheReminderWithoutOpeningFolio() throws {
        let app = launch(with: ["-SeedTestAlertReminder"])
        enableNotifications(in: app)
        XCUIDevice.shared.press(.home)

        let alert = expandDeliveredAlert(titled: "Folio Test Reminder")
        attachScreenshot(named: "ReminderActions")
        alert.buttons["Mark as Done"].firstMatch.tap()

        sleep(3)
        XCTAssertNotEqual(app.state, .runningForeground)
        XCTAssertEqual(springboard.state, .runningForeground)

        app.terminate()
        app.launchArguments = baseArguments + ["-Calendar.ViewMode", "list"]
        app.launch()
        app.tabBars.buttons.element(boundBy: 0).tap()
        let row = app.cells.containing(.staticText, identifier: "Folio Test Reminder").firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10))
        XCTAssertTrue(row.buttons["Mark as Not Completed"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testTappingAMeetingAlertOpensTheMeetingLink() throws {
        let app = launch(with: ["-SeedTestAlertMeeting"])
        enableNotifications(in: app)
        XCUIDevice.shared.press(.home)

        let alert = expandDeliveredAlert(titled: "Folio Test Meeting")
        XCTAssertTrue(alert.buttons["Join Meeting"].firstMatch.exists)
        XCTAssertTrue(alert.buttons["Directions"].firstMatch.exists)
        attachScreenshot(named: "MeetingActions")
        deliveredAlert(titled: "Folio Test Meeting").tap()
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        XCTAssertTrue(safari.wait(for: .runningForeground, timeout: 20))
    }

    @MainActor
    func testTappingAnAlertOpensTheEvent() throws {
        let app = launch(with: ["-SeedTestAlertEvent"])
        enableNotifications(in: app)
        XCUIDevice.shared.press(.home)

        let banner = deliveredAlert(titled: "Folio Test Alert")
        XCTAssertTrue(banner.waitForExistence(timeout: 150))
        banner.tap()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        let noteButton = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'LinkedNote.'")).firstMatch
        XCTAssertTrue(noteButton.waitForExistence(timeout: 10))
        attachScreenshot(named: "OpenedEvent")
    }

    private var baseArguments: [String] {
        ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-FolioSkipOnboarding"]
    }

    @MainActor
    private func launch(with arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = baseArguments + arguments
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        return app
    }

    @MainActor
    private func enableNotifications(in app: XCUIApplication) {
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
        let scheduledCount = app.descendants(matching: .any)["NotificationsScheduledCount"]
        XCTAssertTrue(scheduledCount.waitForExistence(timeout: 10))
        let hasScheduled = NSPredicate { _, _ in !scheduledCount.label.hasSuffix(" 0") && scheduledCount.label != "0" }
        expectation(for: hasScheduled, evaluatedWith: nil)
        waitForExpectations(timeout: 15)
    }

    @MainActor
    private func deliveredAlert(titled title: String) -> XCUIElement {
        springboard.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", title)).firstMatch
    }

    /// Long-pressing the alert shows its actions; it falls back to Notification Center once the banner is gone.
    @MainActor
    private func expandDeliveredAlert(titled title: String) -> XCUIApplication {
        let banner = deliveredAlert(titled: title)
        XCTAssertTrue(banner.waitForExistence(timeout: 150))
        banner.press(forDuration: 1.5)
        if !springboard.buttons["Mark as Done"].waitForExistence(timeout: 3),
           !springboard.buttons["Join Meeting"].exists {
            openNotificationCenter()
            deliveredAlert(titled: title).press(forDuration: 1.5)
        }
        return springboard
    }

    @MainActor
    private func openNotificationCenter() {
        let top = springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.01))
        let middle = springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.6))
        top.press(forDuration: 0.1, thenDragTo: middle)
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
