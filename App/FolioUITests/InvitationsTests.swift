import XCTest

final class InvitationsTests: XCTestCase {
    @MainActor
    private func launch(mode: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-Calendar.ViewMode", mode, "-FolioSkipOnboarding", "-SeedSampleCalendarData", "-SampleInvitations",
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US"
        ]
        app.launch()
        return app
    }

    @MainActor
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testInvitationsListOpensDetailWithAttendeesAndRespondSheet() throws {
        let app = launch(mode: "day")
        let overflow = app.buttons["OverflowBarButtonItem"]
        XCTAssertTrue(overflow.waitForExistence(timeout: 15))
        overflow.tap()
        let invitationsButton = app.buttons["Invitations"]
        XCTAssertTrue(invitationsButton.waitForExistence(timeout: 5))
        invitationsButton.tap()

        let row = app.buttons["InvitationRow"].firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10))
        XCTAssertTrue(row.label.contains("Design Review Day"))
        capture(app, "InvitationsList")
        row.tap()

        XCTAssertTrue(app.descendants(matching: .any)["EventDetailYourResponse"].waitForExistence(timeout: 10))
        capture(app, "EventDetailResponse")
        let summary = app.staticTexts["EventDetailAttendeeSummary"]
        app.swipeUp()
        XCTAssertTrue(summary.waitForExistence(timeout: 5))
        XCTAssertEqual(summary.label, "1 accepted, 1 declined, 1 pending")
        XCTAssertTrue(app.descendants(matching: .any)["EventDetailOrganizer"].exists)
        capture(app, "EventDetailAttendees")

        app.swipeDown()
        let respond = app.buttons["EventDetailRespondButton"]
        XCTAssertTrue(respond.waitForExistence(timeout: 5))
        respond.tap()
        sleep(2)
        capture(app, "RespondSheet")
    }

    @MainActor
    func testDeclinedEventsCanBeHidden() throws {
        let app = launch(mode: "list")
        let concert = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Concert'")).firstMatch
        XCTAssertTrue(app.staticTexts["Standup"].firstMatch.waitForExistence(timeout: 15))
        app.swipeUp()
        XCTAssertTrue(concert.waitForExistence(timeout: 5))
        capture(app, "AgendaDeclined")

        app.buttons["Settings"].tap()
        let toggle = app.switches["HideDeclinedEventsToggle"]
        for _ in 0..<6 where !toggle.isHittable {
            app.swipeUp()
        }
        switchControl(of: toggle).tap()
        app.buttons["Calendar"].tap()

        XCTAssertTrue(app.staticTexts["Team Offsite"].waitForExistence(timeout: 10))
        XCTAssertFalse(concert.waitForExistence(timeout: 3))

        app.buttons["Settings"].tap()
        switchControl(of: toggle).tap()
        app.buttons["Calendar"].tap()
        XCTAssertTrue(concert.waitForExistence(timeout: 10))
    }

    @MainActor
    private func switchControl(of toggle: XCUIElement) -> XCUIElement {
        let inner = toggle.switches.firstMatch
        return inner.exists ? inner : toggle
    }
}
