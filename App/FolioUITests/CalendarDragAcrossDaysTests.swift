import XCTest

final class CalendarDragAcrossDaysTests: XCTestCase {
    @MainActor
    func testDraggingAMonthChipToAnotherDayMovesIt() throws {
        let app = launch(mode: "month")
        let today = Calendar.current.startOfDay(for: .now)
        let sourceDay = app.buttons["MonthDay.\(identifier(of: today, addingDays: 2))"]
        try XCTSkipUnless(sourceDay.waitForExistence(timeout: 10), "The seeded day isn't in this month")
        let targetDay = app.buttons["MonthDay.\(identifier(of: today, addingDays: 1))"]
        let chip = app.staticTexts["Dentist"].firstMatch
        try XCTSkipUnless(chip.waitForExistence(timeout: 10), "Grant calendar access to seed sample data first")

        chip.press(forDuration: 1, thenDragTo: targetDay, withVelocity: 300, thenHoldForDuration: 0.6)

        XCTAssertTrue(app.buttons["UndoToast.Undo"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Moved"].exists)
        XCTAssertTrue(waitForLabel(of: targetDay, containing: "Dentist"))
        add(screenshotAttachment(named: "Month moved", of: app))
    }

    @MainActor
    func testDraggingAnEventToTheNextColumnMovesItToThatDay() throws {
        let app = launch(mode: "multiDay", extra: ["-Calendar.MultiDayCount", "3"])
        let card = app.buttons["Lunch with Aiko"].firstMatch
        try XCTSkipUnless(card.waitForExistence(timeout: 10), "Grant calendar access to seed sample data first")
        let originalX = card.frame.midX
        let start = card.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = start.withOffset(CGVector(dx: card.frame.width + 2, dy: 0))
        start.press(forDuration: 0.8, thenDragTo: end, withVelocity: 200, thenHoldForDuration: 0.5)

        XCTAssertTrue(app.buttons["UndoToast.Undo"].waitForExistence(timeout: 5))
        let moved = NSPredicate { _, _ in card.frame.midX > originalX + card.frame.width / 2 }
        XCTAssertEqual(XCTWaiter.wait(for: [expectation(for: moved, evaluatedWith: nil)], timeout: 5), .completed)
        add(screenshotAttachment(named: "Moved across days", of: app))
    }

    @MainActor
    func testDroppingAnAllDayReminderOnTheTimelineGivesItATime() throws {
        let app = launch(mode: "multiDay", extra: ["-Calendar.MultiDayCount", "3"])
        let reminder = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Send invoice")).firstMatch
        try XCTSkipUnless(reminder.waitForExistence(timeout: 10), "Grant reminders access to seed sample data first")
        let timeline = app.descendants(matching: .any)["TimelineScrollView"].firstMatch
        let start = reminder.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = timeline.coordinate(withNormalizedOffset: CGVector(dx: 0.6, dy: 0.4))
        start.press(forDuration: 0.8, thenDragTo: end, withVelocity: 200, thenHoldForDuration: 0.5)

        XCTAssertTrue(app.buttons["UndoToast.Undo"].waitForExistence(timeout: 5))
        let placed = NSPredicate { _, _ in reminder.exists && reminder.frame.minY > timeline.frame.minY }
        XCTAssertEqual(XCTWaiter.wait(for: [expectation(for: placed, evaluatedWith: nil)], timeout: 5), .completed)
        add(screenshotAttachment(named: "Reminder placed", of: app))
    }

    private func identifier(of date: Date, addingDays days: Int) -> String {
        let day = Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
        return day.formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
    }

    @MainActor
    private func waitForLabel(of element: XCUIElement, containing text: String) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        return XCTWaiter.wait(for: [expectation(for: predicate, evaluatedWith: element)], timeout: 5) == .completed
    }

    @MainActor
    private func launch(mode: String, extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-Calendar.ViewMode", mode,
            "-Calendar.Timeline.Zoom.multiDay", "48", "-UndoToastSeconds", "30",
            "-FolioSkipOnboarding", "-SeedSampleCalendarData"
        ] + extra
        app.launch()
        return app
    }

    @MainActor
    private func screenshotAttachment(named name: String, of app: XCUIApplication) -> XCTAttachment {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        return attachment
    }
}
