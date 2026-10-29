import XCTest

final class CalendarDayPagingTests: XCTestCase {
    private let locale = Locale(identifier: "en_US")

    @MainActor
    func testSwipingPagesTheDayViewOneDayAtATime() throws {
        let app = launch(mode: "day")
        let today = Calendar.current.startOfDay(for: .now)
        XCTAssertTrue(header(for: today, in: app).waitForExistence(timeout: 10))

        app.windows.firstMatch.swipeUp()
        XCTAssertTrue(header(for: today, in: app).waitForExistence(timeout: 2))

        swipe(app, forward: true)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        XCTAssertTrue(header(for: tomorrow, in: app).waitForExistence(timeout: 5))

        swipe(app, forward: false)
        XCTAssertTrue(header(for: today, in: app).waitForExistence(timeout: 5))
        swipe(app, forward: false)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        XCTAssertTrue(header(for: yesterday, in: app).waitForExistence(timeout: 5))
    }

    @MainActor
    func testMultiDayCountSwitchesBetweenTwoAndThreeDays() throws {
        let app = launch(mode: "multiDay")
        let today = Calendar.current.startOfDay(for: .now)
        let thirdDay = Calendar.current.date(byAdding: .day, value: 2, to: today)!
        selectDayCount("3 Days", in: app)
        XCTAssertTrue(header(for: thirdDay, in: app).waitForExistence(timeout: 10))

        selectDayCount("2 Days", in: app)
        XCTAssertTrue(header(for: thirdDay, in: app).waitForNonExistence(timeout: 5))
        let secondDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        XCTAssertTrue(header(for: secondDay, in: app).exists)

        app.terminate()
        app.launchArguments = baseArguments(mode: "multiDay")
        app.launch()
        XCTAssertTrue(header(for: secondDay, in: app).waitForExistence(timeout: 10))
        XCTAssertFalse(header(for: thirdDay, in: app).exists)
    }

    @MainActor
    private func selectDayCount(_ title: String, in app: XCUIApplication) {
        let picker = app.buttons["Number of Days"]
        XCTAssertTrue(picker.waitForExistence(timeout: 10))
        picker.tap()
        app.buttons[title].tap()
    }

    @MainActor
    private func swipe(_ app: XCUIApplication, forward: Bool) {
        let window = app.windows.firstMatch
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: forward ? 0.85 : 0.3, dy: 0.6))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: forward ? 0.3 : 0.85, dy: 0.6))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .fast, thenHoldForDuration: 0)
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
