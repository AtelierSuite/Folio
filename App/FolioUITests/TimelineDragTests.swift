import XCTest

final class TimelineDragTests: XCTestCase {
    private let eventTitle = "Lunch with Aiko"
    private let hourHeight: CGFloat = 60

    @MainActor
    func testLongPressDraggingAnEventMovesItAndShowsTheUndoToast() throws {
        let app = launch()
        let card = try eventCard(in: app)
        XCTAssertTrue(waitForValue(of: card, prefix: "12:30 PM"))

        let start = card.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = start.withOffset(CGVector(dx: 0, dy: hourHeight * 2))
        start.press(forDuration: 0.8, thenDragTo: end, withVelocity: 200, thenHoldForDuration: 0.5)

        XCTAssertTrue(app.buttons["UndoToast.Undo"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Moved"].exists)
        XCTAssertTrue(waitForValue(of: card, prefix: "2:30 PM"))
        add(screenshotAttachment(named: "Moved toast", of: app))

        app.buttons["UndoToast.Undo"].tap()
        XCTAssertTrue(waitForValue(of: card, prefix: "12:30 PM"))
    }

    @MainActor
    func testDraggingTheBottomEdgeResizesAnEvent() throws {
        let app = launch()
        let card = try eventCard(in: app)
        let bottomEdge = card.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1))
            .withOffset(CGVector(dx: 0, dy: -5))
        let end = bottomEdge.withOffset(CGVector(dx: 0, dy: hourHeight))
        bottomEdge.press(forDuration: 0.8, thenDragTo: end, withVelocity: 200, thenHoldForDuration: 0.5)

        XCTAssertTrue(app.buttons["UndoToast.Undo"].waitForExistence(timeout: 5))
        XCTAssertTrue(waitForValue(of: card, prefix: "12:30 PM – 2:30 PM"))
        add(screenshotAttachment(named: "Resized", of: app))
    }

    @MainActor
    func testTappingAnEventStillOpensIt() throws {
        let app = launch()
        try eventCard(in: app).tap()
        XCTAssertTrue(app.staticTexts[eventTitle].firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["UndoToast.Undo"].exists)
    }

    @MainActor
    private func eventCard(in app: XCUIApplication) throws -> XCUIElement {
        let card = app.buttons[eventTitle].firstMatch
        try XCTSkipUnless(card.waitForExistence(timeout: 10), "Grant calendar access to seed sample data first")
        return card
    }

    @MainActor
    /// Times are formatted with a narrow no-break space before AM and PM.
    private func waitForValue(of element: XCUIElement, prefix: String) -> Bool {
        let deadline = Date.now.addingTimeInterval(5)
        repeat {
            let value = (element.value as? String)?.replacingOccurrences(of: "\u{202F}", with: " ")
            if value?.hasPrefix(prefix) == true { return true }
            RunLoop.current.run(until: .now.addingTimeInterval(0.25))
        } while Date.now < deadline
        return false
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-Calendar.ViewMode", "day",
            "-Calendar.Timeline.Zoom.day", "\(Int(hourHeight))", "-Calendar.Drag.SnapMinutes", "15",
            "-UndoToastSeconds", "30", "-FolioSkipOnboarding", "-SeedSampleCalendarData"
        ]
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
