import XCTest

final class EventQuickActionsTests: XCTestCase {
    @MainActor
    func testTapOpensDetailsByDefaultAndLongPressShowsTheMenu() throws {
        let app = launch(mode: "day", behavior: "opensDetails")
        let card = eventCard("Lunch with Aiko", in: app)
        card.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 10))
        app.buttons["Done"].tap()

        card.press(forDuration: 1.2)
        let showDetails = menuItem("EventMenu.ShowDetails", title: "Show Details", in: app)
        XCTAssertTrue(showDetails.waitForExistence(timeout: 5))
        XCTAssertTrue(menuItem("EventMenu.Delete", title: "Delete", in: app).exists)
        attachScreenshot(named: "details-mode-long-press", app: app)
        showDetails.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testTapShowsQuickActionsWhenChosen() throws {
        let app = launch(mode: "day", behavior: "showsQuickActions")
        let card = eventCard("Lunch with Aiko", in: app)
        card.tap()
        let showDetails = menuItem("EventMenu.ShowDetails", in: app)
        XCTAssertTrue(showDetails.waitForExistence(timeout: 5))
        XCTAssertTrue(menuItem("EventMenu.Copy", in: app).exists)
        XCTAssertFalse(app.buttons["Done"].exists)
        attachScreenshot(named: "quick-actions-timeline", app: app)
        showDetails.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 10))
        app.buttons["Done"].tap()

        eventCard("Design Sync", in: app).tap()
        XCTAssertTrue(menuItem("EventMenu.JoinMeeting", in: app).waitForExistence(timeout: 5))
    }

    @MainActor
    func testTappingAMonthChipShowsQuickActions() throws {
        let app = launch(mode: "month", behavior: "showsQuickActions")
        // The Dentist day has two events and no reminders, so its first chip is always an event.
        let dentistDay = try XCTUnwrap(app.monthCell(for: XCUIApplication.day(2), containing: "Dentist"))
        dentistDay.monthChipCoordinate(row: 0).tap()
        XCTAssertTrue(menuItem("EventMenu.ShowDetails", in: app).waitForExistence(timeout: 5))
        attachScreenshot(named: "quick-actions-month-chip", app: app)
    }

    @MainActor
    func testMonthChipLongPressShowsTheMenuInDetailsMode() throws {
        // Writable chips lift to drag on a long press, so this uses the read-only sample invitation.
        let app = launch(mode: "month", behavior: "opensDetails", extra: ["-SampleInvitations"])
        let reviewDay = try XCTUnwrap(app.monthCell(for: XCUIApplication.day(1), containing: "Design Review Day"))
        let respond = menuItem("EventMenu.Respond", in: app)
        // Other tests can leave events on this day, so the chip's row varies; try each row in turn.
        for row in 0..<6 where !respond.exists {
            reviewDay.monthChipCoordinate(row: row).press(forDuration: 1.2)
            _ = respond.waitForExistence(timeout: 2)
        }
        XCTAssertTrue(respond.exists)
        XCTAssertFalse(menuItem("EventMenu.Edit", in: app).exists)
        attachScreenshot(named: "details-mode-month-chip-long-press", app: app)
    }

    @MainActor
    func testPinchStillZoomsWithQuickActions() throws {
        let app = launch(mode: "day", behavior: "showsQuickActions", extra: ["-Calendar.Timeline.Zoom.day", "0"])
        _ = eventCard("Lunch with Aiko", in: app)
        let timeline = app.descendants(matching: .any)["TimelineScrollView"].firstMatch
        XCTAssertTrue(timeline.waitForExistence(timeout: 10))
        timeline.pinch(withScale: 3, velocity: 2)
        XCTAssertFalse(menuItem("EventMenu.ShowDetails", in: app).exists)
        let overflow = app.buttons["OverflowBarButtonItem"].firstMatch
        XCTAssertTrue(overflow.waitForExistence(timeout: 10))
        overflow.tap()
        XCTAssertTrue(app.buttons["Zoom Out"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Zoom Out"].isEnabled)
    }

    @MainActor
    func testCountdownStartsAndStopsFromTheMenu() throws {
        // The agenda lists the next week, so the event 30 minutes out shows even late in the evening.
        let app = launch(mode: "list", behavior: "showsQuickActions", extra: ["-SeedCountdownEvent"])
        let event = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Folio Countdown")).firstMatch
        try XCTSkipUnless(event.waitForExistence(timeout: 15), "Grant calendar access to seed the event")
        event.tap()
        let start = menuItem("EventMenu.StartCountdown", in: app)
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        start.tap()
        event.tap()
        let stop = menuItem("EventMenu.StopCountdown", in: app)
        XCTAssertTrue(stop.waitForExistence(timeout: 5))
        attachScreenshot(named: "quick-actions-stop-countdown", app: app)
        stop.tap()
        event.tap()
        XCTAssertTrue(menuItem("EventMenu.StartCountdown", in: app).waitForExistence(timeout: 5))
        menuItem("EventMenu.Copy", in: app).tap()
    }

    @MainActor
    func testRespondOpensTheInvitationFromAnAgendaRow() throws {
        let app = launch(mode: "list", behavior: "showsQuickActions", extra: ["-SampleInvitations"])
        let row = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH 'Invitation' AND label CONTAINS 'Lunch with Aiko'")
        ).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 15))
        row.tap()
        let respond = menuItem("EventMenu.Respond", in: app)
        XCTAssertTrue(respond.waitForExistence(timeout: 5))
        XCTAssertFalse(menuItem("EventMenu.Edit", in: app).exists)
        attachScreenshot(named: "quick-actions-invitation", app: app)
        respond.tap()
        // The sample invitation's attendees are decorations Folio adds, so Apple's sheet shows the
        // event without Accept and Decline here; with a real invitation it shows them too.
        XCTAssertTrue(app.navigationBars["Event Details"].waitForExistence(timeout: 10))
        attachScreenshot(named: "quick-actions-respond-sheet", app: app)
    }

    @MainActor
    func testSettingSwitchesTheTapBehavior() throws {
        let app = launch(mode: "day", behavior: nil)
        app.tabBars.buttons["Settings"].firstMatch.tap()
        let picker = app.buttons["EventTapBehaviorPicker"].firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 10))
        picker.tap()
        app.buttons["Shows Quick Actions"].firstMatch.tap()
        app.tabBars.buttons["Calendar"].firstMatch.tap()
        eventCard("Lunch with Aiko", in: app).tap()
        XCTAssertTrue(menuItem("EventMenu.ShowDetails", in: app).waitForExistence(timeout: 5))
        menuItem("EventMenu.Copy", in: app).tap()

        app.tabBars.buttons["Settings"].firstMatch.tap()
        XCTAssertTrue(picker.waitForExistence(timeout: 10))
        picker.tap()
        app.buttons["Opens Details"].firstMatch.tap()
        app.tabBars.buttons["Calendar"].firstMatch.tap()
        eventCard("Lunch with Aiko", in: app).tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 10))
    }

    @MainActor
    private func eventCard(_ title: String, in app: XCUIApplication) -> XCUIElement {
        let card = app.buttons[title].firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 15))
        return card
    }

    @MainActor
    private func menuItem(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    /// SwiftUI context menus drop identifiers, while menus opened at a tap point keep them.
    @MainActor
    private func menuItem(_ identifier: String, title: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@ OR (label == %@ AND elementType == %d)",
                                  identifier, title, XCUIElement.ElementType.button.rawValue))
            .firstMatch
    }

    @MainActor
    private func attachScreenshot(named name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func launch(mode: String, behavior: String?, extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        var arguments = [
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-Calendar.ViewMode", mode,
            "-FolioSkipOnboarding", "-SeedSampleCalendarData"
        ]
        if let behavior {
            arguments += ["-Calendar.EventTapBehavior", behavior]
        }
        app.launchArguments = arguments + extra
        app.launch()
        return app
    }
}
