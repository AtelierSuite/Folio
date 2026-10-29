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
        let today = try visibleToday(in: app)
        today.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45)).tap()
        XCTAssertTrue(menuItem("EventMenu.ShowDetails", in: app).waitForExistence(timeout: 5))
        attachScreenshot(named: "quick-actions-month-chip", app: app)
    }

    @MainActor
    func testMonthChipLongPressShowsTheMenuInDetailsMode() throws {
        let app = launch(mode: "month", behavior: "opensDetails")
        let today = try visibleToday(in: app)
        today.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45)).press(forDuration: 1.2)
        XCTAssertTrue(menuItem("EventMenu.ShowDetails", in: app).waitForExistence(timeout: 5))
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
        let app = launch(mode: "day", behavior: "showsQuickActions", extra: ["-SeedCountdownEvent"])
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

    /// Neighbouring month pages also show today's date, so this picks the cell on screen.
    @MainActor
    private func visibleToday(in app: XCUIApplication) throws -> XCUIElement {
        let today = Date.now.formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
        let identifier = "MonthDay." + today
        let cells = app.buttons.matching(identifier: identifier)
        XCTAssertTrue(cells.firstMatch.waitForExistence(timeout: 15))
        let width = app.windows.firstMatch.frame.width
        let cell = try XCTUnwrap(cells.allElementsBoundByIndex.first { $0.frame.minX >= 0 && $0.frame.maxX <= width })
        let loaded = NSPredicate(format: "label CONTAINS 'Standup'")
        expectation(for: loaded, evaluatedWith: cell)
        waitForExpectations(timeout: 15)
        return cell
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
