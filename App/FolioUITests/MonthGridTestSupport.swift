import XCTest

/// The month view lays pages side by side and neighbouring pages repeat dates, and the seeded
/// days can fall in next month. These helpers find the cell for a date on the page on screen,
/// paging forward to the month that shows it.
extension XCUIApplication {
    static func monthDayIdentifier(for date: Date) -> String {
        "MonthDay." + date.formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
    }

    static func day(_ offset: Int, from date: Date = .now) -> Date {
        let today = Calendar.current.startOfDay(for: date)
        return Calendar.current.date(byAdding: .day, value: offset, to: today) ?? today
    }

    /// The on-screen cell for `date` whose label lists `title`, after paging forward up to twice.
    @MainActor
    func monthCell(for date: Date, containing title: String) -> XCUIElement? {
        for attempt in 0..<3 {
            if let cell = onScreenMonthCell(for: date, containing: title, timeout: 10) {
                return cell
            }
            guard attempt < 2 else { break }
            buttons["Next"].firstMatch.tap()
        }
        return nil
    }

    /// The cell for `date` on the page that's already on screen, if that page shows it.
    @MainActor
    func onScreenMonthCell(for date: Date, containing title: String? = nil, timeout: TimeInterval = 2) -> XCUIElement? {
        let cells = buttons.matching(identifier: Self.monthDayIdentifier(for: date))
        let deadline = Date.now.addingTimeInterval(timeout)
        repeat {
            let width = windows.firstMatch.frame.width
            let onScreen = cells.allElementsBoundByIndex.first { cell in
                cell.exists && cell.frame.minX >= -1 && cell.frame.maxX <= width + 1
            }
            if let onScreen, title.map({ onScreen.label.contains($0) }) ?? true {
                return onScreen
            }
            RunLoop.current.run(until: .now.addingTimeInterval(0.25))
        } while Date.now < deadline
        return nil
    }
}

extension XCUIElement {
    /// A point on the chip in `row` of a month cell, counting from the first chip under the day number.
    func monthChipCoordinate(row: Int) -> XCUICoordinate {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0))
            .withOffset(CGVector(dx: 0, dy: 32 + CGFloat(row) * 17))
    }
}
