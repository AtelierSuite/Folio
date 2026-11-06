import XCTest

final class WeekSingleDayLayoutTests: XCTestCase {
    @MainActor
    func testTappingADayInTheWeekRowSelectsIt() {
        let app = launch(viewMode: "week")

        let weekDays = app.onScreenWeekDays
        XCTAssertEqual(weekDays.count, 7)

        let unselected = weekDays.first { !$0.isSelected } ?? weekDays[0]
        unselected.tap()
        XCTAssertTrue(unselected.isSelected)
        XCTAssertEqual(app.onScreenWeekDays.filter(\.isSelected).count, 1)
    }

    @MainActor
    func testWorkWeekRowOnlyShowsWorkdays() {
        let app = launch(viewMode: "workWeek")

        XCTAssertFalse(app.buttons["WeekDayRow.Day.1"].exists)
        XCTAssertEqual(app.onScreenWeekDays.count, 5)
    }

    @MainActor
    func testSwipingTheWeekRowScrollsToTheNextWeek() throws {
        let app = launch(viewMode: "week")

        let firstDay = try XCTUnwrap(app.onScreenWeekDays.first)
        let weekBeforeSwipe = firstDay.label
        firstDay.swipeLeft()

        let predicate = NSPredicate { _, _ in
            app.onScreenWeekDays.first?.label != weekBeforeSwipe
        }
        wait(for: [XCTNSPredicateExpectation(predicate: predicate, object: nil)], timeout: 5)
        XCTAssertEqual(app.onScreenWeekDays.count, 7)
        XCTAssertEqual(app.onScreenWeekDays.filter(\.isSelected).count, 1)
    }

    @MainActor
    private func launch(viewMode: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-Calendar.ViewMode", viewMode, "-Calendar.WeekLayout", "singleDay", "-FolioSkipOnboarding"
        ]
        app.launch()
        XCTAssertTrue(app.weekDayButtons.firstMatch.waitForExistence(timeout: 10))
        return app
    }
}

private extension XCUIApplication {
    var weekDayButtons: XCUIElementQuery {
        buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "WeekDayRow.Day."))
    }

    /// The row keeps the neighbouring weeks built, so only the days inside the window are the week in view.
    var onScreenWeekDays: [XCUIElement] {
        let windowFrame = windows.firstMatch.frame
        return weekDayButtons.allElementsBoundByIndex.filter { day in
            windowFrame.contains(CGPoint(x: day.frame.midX, y: day.frame.midY))
        }
    }
}
