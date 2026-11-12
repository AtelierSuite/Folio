import XCTest

final class LinkedNotesTests: XCTestCase {
    @MainActor
    func testDayViewCreatesAndShowsTheDailyNote() throws {
        let app = launch()
        openDailyNoteFromAddMenu(in: app)
        XCTAssertTrue(app.buttons["DailyNote.Open"].waitForExistence(timeout: 10))
        attachScreenshot(named: "day-view-daily-note", app: app)
    }

    @MainActor
    func testNoteDeepLinkOpensTheNote() throws {
        let app = launch()
        openDailyNoteFromAddMenu(in: app)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let dayKey = formatter.string(from: .now)
        let link = try XCTUnwrap(URL(string: "folio://note/Daily/\(dayKey).md"))
        app.open(link)
        confirmOpeningInFolio()
        XCTAssertTrue(app.staticTexts[dayKey].waitForExistence(timeout: 10))
        attachScreenshot(named: "deep-link", app: app)
    }

    @MainActor
    private func openDailyNoteFromAddMenu(in app: XCUIApplication) {
        let addMenu = app.buttons["Add"].firstMatch
        XCTAssertTrue(addMenu.waitForExistence(timeout: 10))
        addMenu.tap()
        let dailyNote = app.buttons
            .matching(NSPredicate(format: "label IN %@", ["Create Daily Note", "Open Daily Note"])).firstMatch
        XCTAssertTrue(dailyNote.waitForExistence(timeout: 10))
        attachScreenshot(named: "add-menu-daily-note", app: app)
        dailyNote.tap()
        XCTAssertTrue(app.textViews.firstMatch.waitForExistence(timeout: 10))
        app.tabBars.buttons["Schedule"].firstMatch.tap()
    }

    /// iOS asks before opening a custom URL scheme; the button title follows the system language.
    @MainActor
    private func confirmOpeningInFolio() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let openButton = springboard.buttons.matching(NSPredicate(format: "label IN %@", ["Open", "開く"])).firstMatch
        if openButton.waitForExistence(timeout: 5) {
            openButton.tap()
        }
    }

    @MainActor
    private func attachScreenshot(named name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-Calendar.ViewMode", "day",
            "-FolioSkipOnboarding"
        ]
        app.launch()
        return app
    }
}
