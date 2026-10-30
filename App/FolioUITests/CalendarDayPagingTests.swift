import XCTest

final class CalendarDayPagingTests: XCTestCase {
    private let locale = Locale(identifier: "en_US")

    @MainActor
    func testSwipingScrollsTheDayViewOneDayAtATime() throws {
        let app = launch(mode: "day")
        let today = Calendar.current.startOfDay(for: .now)
        XCTAssertTrue(waitUntilOnScreen(header(for: today, in: app), in: app, timeout: 10))

        app.windows.firstMatch.swipeUp()
        XCTAssertTrue(waitUntilOnScreen(header(for: today, in: app), in: app))

        swipe(app, forward: true)
        let tomorrow = day(1, after: today)
        XCTAssertTrue(waitUntilOnScreen(header(for: tomorrow, in: app), in: app))
        XCTAssertFalse(isOnScreen(header(for: today, in: app), in: app))

        swipe(app, forward: false)
        XCTAssertTrue(waitUntilOnScreen(header(for: today, in: app), in: app))
        swipe(app, forward: false)
        XCTAssertTrue(waitUntilOnScreen(header(for: day(-1, after: today), in: app), in: app))
    }

    @MainActor
    func testFlingCarriesTheDayViewAcrossSeveralDays() throws {
        let app = launch(mode: "day")
        let today = Calendar.current.startOfDay(for: .now)
        XCTAssertTrue(waitUntilOnScreen(header(for: today, in: app), in: app, timeout: 10))

        fling(app)
        XCTAssertTrue(waitUntilOffScreen(header(for: today, in: app), in: app))
        RunLoop.current.run(until: .now.addingTimeInterval(2))
        XCTAssertFalse(isOnScreen(header(for: day(1, after: today), in: app), in: app))
        XCTAssertTrue(app.buttons["Today"].firstMatch.isEnabled)
        add(screenshotAttachment(named: "After fling", of: app))

        app.buttons["Today"].firstMatch.tap()
        XCTAssertTrue(waitUntilOnScreen(header(for: today, in: app), in: app))
    }

    @MainActor
    func testSwipingTheWeekViewShowsTheNextWeekAndKeepsTheTitleInStep() throws {
        let app = launch(mode: "week")
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        XCTAssertTrue(waitUntilOnScreen(header(for: today, in: app), in: app, timeout: 10))

        for week in 1...5 {
            swipe(app, forward: true)
            let sameWeekday = day(7 * week, after: today)
            XCTAssertTrue(waitUntilOnScreen(header(for: sameWeekday, in: app), in: app), "Week \(week)")
        }
        let expectedTitle = day(35, after: today).formatted(Date.FormatStyle().year().month(.wide).locale(locale))
        XCTAssertTrue(app.navigationBars[expectedTitle].waitForExistence(timeout: 5))

        app.buttons["Today"].firstMatch.tap()
        XCTAssertTrue(waitUntilOnScreen(header(for: today, in: app), in: app))
        let todayTitle = today.formatted(Date.FormatStyle().year().month(.wide).locale(locale))
        XCTAssertTrue(app.navigationBars[todayTitle].waitForExistence(timeout: 5))
    }

    @MainActor
    func testForwardButtonScrollsTheMultiDayViewByOneDay() throws {
        let app = launch(mode: "multiDay")
        selectDayCount("3 Days", in: app)
        let today = Calendar.current.startOfDay(for: .now)
        XCTAssertTrue(waitUntilOnScreen(header(for: today, in: app), in: app, timeout: 10))

        app.buttons["Next"].firstMatch.tap()
        XCTAssertTrue(waitUntilOnScreen(header(for: day(3, after: today), in: app), in: app))
        XCTAssertFalse(isOnScreen(header(for: today, in: app), in: app))
    }

    @MainActor
    func testMultiDayCountSwitchesBetweenTwoAndThreeDays() throws {
        let app = launch(mode: "multiDay")
        let today = Calendar.current.startOfDay(for: .now)
        let thirdDay = Calendar.current.date(byAdding: .day, value: 2, to: today)!
        selectDayCount("3 Days", in: app)
        XCTAssertTrue(waitUntilOnScreen(header(for: thirdDay, in: app), in: app, timeout: 10))

        selectDayCount("2 Days", in: app)
        XCTAssertTrue(waitUntilOffScreen(header(for: thirdDay, in: app), in: app))
        let secondDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        XCTAssertTrue(isOnScreen(header(for: secondDay, in: app), in: app))

        app.terminate()
        app.launchArguments = baseArguments(mode: "multiDay")
        app.launch()
        XCTAssertTrue(waitUntilOnScreen(header(for: secondDay, in: app), in: app, timeout: 10))
        XCTAssertFalse(isOnScreen(header(for: thirdDay, in: app), in: app))
    }

    @MainActor
    private func selectDayCount(_ title: String, in app: XCUIApplication) {
        let picker = app.buttons["Number of Days"]
        if !picker.waitForExistence(timeout: 5) {
            app.buttons["OverflowBarButtonItem"].firstMatch.tap()
        }
        XCTAssertTrue(picker.waitForExistence(timeout: 10))
        picker.tap()
        app.buttons[title].tap()
    }

    @MainActor
    private func fling(_ app: XCUIApplication) {
        let window = app.windows.firstMatch
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.6))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.6))
        start.press(forDuration: 0.02, thenDragTo: end, withVelocity: 4000, thenHoldForDuration: 0)
    }

    private func day(_ offset: Int, after date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: date)!
    }

    /// A drag released without much speed, so it settles on the next day rather than flinging past it.
    @MainActor
    private func swipe(_ app: XCUIApplication, forward: Bool) {
        let window = app.windows.firstMatch
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: forward ? 0.85 : 0.3, dy: 0.6))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: forward ? 0.3 : 0.85, dy: 0.6))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: 600, thenHoldForDuration: 0.1)
    }

    /// Neighbouring pages are rendered too, so a header only counts once it's inside the window,
    /// right of the hour labels.
    @MainActor
    private func isOnScreen(_ element: XCUIElement, in app: XCUIApplication) -> Bool {
        guard element.exists else { return false }
        let window = app.windows.firstMatch.frame
        let midX = element.frame.midX
        return midX > window.minX + 52 && midX < window.maxX
    }

    @MainActor
    private func waitUntilOnScreen(
        _ element: XCUIElement, in app: XCUIApplication, timeout: TimeInterval = 10
    ) -> Bool {
        let predicate = NSPredicate { _, _ in self.isOnScreen(element, in: app) }
        return XCTWaiter.wait(for: [expectation(for: predicate, evaluatedWith: nil)], timeout: timeout) == .completed
    }

    @MainActor
    private func waitUntilOffScreen(_ element: XCUIElement, in app: XCUIApplication) -> Bool {
        let predicate = NSPredicate { _, _ in !self.isOnScreen(element, in: app) }
        return XCTWaiter.wait(for: [expectation(for: predicate, evaluatedWith: nil)], timeout: 10) == .completed
    }

    @MainActor
    private func screenshotAttachment(named name: String, of app: XCUIApplication) -> XCTAttachment {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        return attachment
    }

    @MainActor
    private func launch(mode: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = baseArguments(mode: mode)
        app.launch()
        return app
    }

    private func baseArguments(mode: String) -> [String] {
        ["-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-Calendar.ViewMode", mode, "-FolioSkipOnboarding"]
    }

    @MainActor
    private func header(for date: Date, in app: XCUIApplication) -> XCUIElement {
        let label = date.formatted(Date.FormatStyle(date: .complete).locale(locale))
        return app.descendants(matching: .any)[label].firstMatch
    }
}
