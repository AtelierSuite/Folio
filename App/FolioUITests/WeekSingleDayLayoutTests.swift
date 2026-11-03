import XCTest

final class WeekSingleDayLayoutTests: XCTestCase {
    @MainActor
    func testTappingADayInTheWeekRowSelectsIt() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-Calendar.ViewMode", "week", "-Calendar.WeekLayout", "singleDay", "-FolioSkipOnboarding"
        ]
        app.launch()

        let weekDays = (1...7).map { app.buttons["WeekDayRow.Day.\($0)"] }
        XCTAssertTrue(weekDays[0].waitForExistence(timeout: 10))
        XCTAssertTrue(weekDays.allSatisfy(\.exists))

        let unselected = weekDays.first { !$0.isSelected } ?? weekDays[0]
        unselected.tap()
        XCTAssertTrue(unselected.isSelected)
        XCTAssertEqual(weekDays.filter(\.isSelected).count, 1)
    }

    @MainActor
    func testWorkWeekRowOnlyShowsWorkdays() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-Calendar.ViewMode", "workWeek", "-Calendar.WeekLayout", "singleDay", "-FolioSkipOnboarding"
        ]
        app.launch()

        XCTAssertTrue(app.buttons["WeekDayRow.Day.2"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["WeekDayRow.Day.1"].exists)
        XCTAssertEqual(app.buttons.matching(where: "WeekDayRow.Day.").count, 5)
    }
}

private extension XCUIElementQuery {
    func matching(where identifierPrefix: String) -> XCUIElementQuery {
        matching(NSPredicate(format: "identifier BEGINSWITH %@", identifierPrefix))
    }
}
