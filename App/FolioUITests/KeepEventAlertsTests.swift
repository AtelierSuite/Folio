import XCTest

final class KeepEventAlertsTests: XCTestCase {
    private static let alertTitle = "Folio Test Alert"

    @MainActor
    private var springboard: XCUIApplication {
        XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testTappedAlertStaysInNotificationCenterWithoutABanner() throws {
        let app = launchWithNotificationsEnabled()
        turnOnKeepEventAlerts(in: app)
        XCUIDevice.shared.press(.home)

        tapDeliveredBanner(opening: app)
        expectNoBanner()
        expectAlertInNotificationCenter(screenshot: "KeptAfterTappingBanner")
    }

    @MainActor
    private var deliveredAlert: XCUIElement {
        springboard.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS[c] %@", Self.alertTitle)).firstMatch
    }

    @MainActor
    private func launchWithNotificationsEnabled() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-FolioSkipOnboarding", "-SeedTestAlertEvent"
        ]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        app.tabBars.buttons["Settings"].firstMatch.tap()
        app.buttons["NotificationSettingsLink"].tap()
        app.allowNotificationsIfPrompted()
        let toggle = app.switches["NotificationsEnabledToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        if toggle.value as? String != "1" {
            toggle.switches.firstMatch.tap()
            let allow = springboard.alerts.buttons.element(boundBy: 1)
            if allow.waitForExistence(timeout: 5) {
                allow.tap()
            }
        }
        app.navigationBars.buttons.element(boundBy: 0).tap()
        return app
    }

    @MainActor
    private func turnOnKeepEventAlerts(in app: XCUIApplication) {
        app.openSettingsCategory("eventNotifications")
        let toggle = app.switches["KeepEventAlertsToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        if toggle.value as? String != "1" {
            toggle.switches.firstMatch.tap()
        }
    }

    @MainActor
    private func tapDeliveredBanner(opening app: XCUIApplication) {
        XCTAssertTrue(deliveredAlert.waitForExistence(timeout: 150))
        deliveredAlert.tap()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }

    @MainActor
    private func expectNoBanner() {
        let appeared = deliveredAlert.waitForExistence(timeout: 5)
        attachScreenshot(named: "NoBanner")
        XCTAssertFalse(appeared)
    }

    @MainActor
    private func expectAlertInNotificationCenter(screenshot name: String) {
        XCUIDevice.shared.press(.home)
        let top = springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.01))
        let middle = springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.6))
        top.press(forDuration: 0.1, thenDragTo: middle)
        let found = deliveredAlert.waitForExistence(timeout: 10)
        attachScreenshot(named: name)
        XCTAssertTrue(found)
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
