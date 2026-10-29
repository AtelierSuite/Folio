import XCTest

final class MonthViewTests: XCTestCase {
    @MainActor
    func testSwipingPagesMonthsAndTappingADaySelectsIt() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Calendar.ViewMode", "month"]
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
    private func waitForLabel(of element: XCUIElement, toDifferFrom label: String) -> Bool {
        let predicate = NSPredicate(format: "label != %@", label)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: 5) == .completed
    }
}
