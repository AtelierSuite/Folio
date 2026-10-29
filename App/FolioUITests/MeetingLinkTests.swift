import XCTest

final class MeetingLinkTests: XCTestCase {
    @MainActor
    func testJoinButtonsAppearOnCardsDetailAndAgenda() throws {
        let app = launch(mode: "day")
        let card = app.buttons["Design Sync"].firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 15))
        XCTAssertTrue(joinButtons(in: app).firstMatch.waitForExistence(timeout: 5))
        attachScreenshot(named: "card-join", app: app)
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        joinButtons(in: app).firstMatch.tap()
        XCTAssertTrue(safari.wait(for: .runningForeground, timeout: 15))
        app.activate()
        XCTAssertFalse(app.buttons["Done"].exists)

        card.tap()
        let detailJoin = joinButtons(in: app).matching(NSPredicate(format: "label == %@", "Join Zoom")).firstMatch
        XCTAssertTrue(detailJoin.waitForExistence(timeout: 10))
        attachScreenshot(named: "detail-join", app: app)
        safari.terminate()
        detailJoin.tap()
        XCTAssertTrue(safari.wait(for: .runningForeground, timeout: 15))

        app.terminate()
        app.launchArguments = arguments(mode: "list")
        app.launch()
        let row = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Design Sync")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 15))
        XCTAssertGreaterThanOrEqual(joinButtons(in: app).count, 2)
        attachScreenshot(named: "agenda-join", app: app)
    }

    @MainActor
    private func joinButtons(in app: XCUIApplication) -> XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: "JoinMeeting")
    }

    @MainActor
    private func attachScreenshot(named name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func launch(mode: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = arguments(mode: mode)
        app.launch()
        return app
    }

    private func arguments(mode: String) -> [String] {
        [
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-Calendar.ViewMode", mode,
            "-FolioSkipOnboarding", "-SeedSampleCalendarData"
        ]
    }
}
