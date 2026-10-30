import XCTest

final class MonthViewTests: XCTestCase {
    @MainActor
    func testSwipingPagesMonthsAndTappingADaySelectsIt() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Calendar.ViewMode", "month", "-FolioSkipOnboarding"]
        app.launch()

        let title = app.navigationBars.firstMatch.staticTexts.firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 10))
        let initialTitle = title.label

        app.scrollViews.firstMatch.swipeLeft()
        XCTAssertTrue(waitForLabel(of: title, toDifferFrom: initialTitle))
        let nextTitle = title.label

        app.scrollViews.firstMatch.swipeRight()
        XCTAssertTrue(waitForLabel(of: title, toDifferFrom: nextTitle))
        XCTAssertEqual(title.label, initialTitle)

        let calendar = Calendar.current
        let monthStart = try XCTUnwrap(calendar.dateInterval(of: .month, for: .now)?.start)
        let target = try XCTUnwrap(calendar.date(byAdding: .day, value: 14, to: monthStart))
        let identifier = target.formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
        let day = app.buttons["MonthDay.\(identifier)"]
        XCTAssertTrue(day.waitForExistence(timeout: 5))
        day.tap()
        XCTAssertTrue(day.wait(for: \.isSelected, toEqual: true, timeout: 5))
    }

    @MainActor
    func testSwipingKeepsPagingPastTheWindowOfMonths() throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-Calendar.ViewMode", "month", "-FolioSkipOnboarding"
        ]
        app.launch()
        XCTAssertTrue(app.scrollViews.firstMatch.waitForExistence(timeout: 10))

        let calendar = Calendar.current
        for offset in 1...10 {
            app.scrollViews.firstMatch.swipeLeft()
            let month = try XCTUnwrap(calendar.date(byAdding: .month, value: offset, to: .now))
            let title = month.formatted(Date.FormatStyle().year().month(.wide).locale(Locale(identifier: "en_US")))
            XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5), "Month \(offset)")
        }
        app.buttons["Today"].firstMatch.tap()
        let title = Date.now.formatted(Date.FormatStyle().year().month(.wide).locale(Locale(identifier: "en_US")))
        XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5))
    }

    @MainActor
    private func waitForLabel(of element: XCUIElement, toDifferFrom label: String) -> Bool {
        let predicate = NSPredicate(format: "label != %@", label)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: 5) == .completed
    }
}
