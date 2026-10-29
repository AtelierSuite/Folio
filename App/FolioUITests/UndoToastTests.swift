import XCTest

final class UndoToastTests: XCTestCase {
    private let eventTitle = "Dentist"

    @MainActor
    func testUndoingADeleteBringsTheEventBack() throws {
        let app = launch(seeding: true, toastSeconds: 30)
        try deleteEvent(in: app)

        let undoButton = app.buttons["UndoToast.Undo"]
        XCTAssertTrue(undoButton.waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Deleted"].exists)
        XCTAssertTrue(app.staticTexts[eventTitle].waitForNonExistence(timeout: 2))
        add(screenshotAttachment(named: "Deleted toast", of: app))

        undoButton.tap()
        XCTAssertTrue(app.staticTexts[eventTitle].waitForExistence(timeout: 5))
        XCTAssertTrue(undoButton.waitForNonExistence(timeout: 2))
    }

    @MainActor
    func testTheDeleteIsWrittenWhenTheToastExpires() throws {
        let app = launch(seeding: true)
        try deleteEvent(in: app)
        XCTAssertTrue(app.buttons["UndoToast.Undo"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["UndoToast.Undo"].waitForNonExistence(timeout: 8))

        app.terminate()
        let relaunched = launch(seeding: false)
        XCTAssertTrue(relaunched.staticTexts["Lunch with Aiko"].waitForExistence(timeout: 10))
        XCTAssertFalse(relaunched.staticTexts[eventTitle].exists)
    }

    @MainActor
    func testQuittingWithinTheWindowDeletesNothing() throws {
        let app = launch(seeding: true)
        try deleteEvent(in: app)
        XCTAssertTrue(app.buttons["UndoToast.Undo"].waitForExistence(timeout: 2))
        app.terminate()

        let relaunched = launch(seeding: false)
        XCTAssertTrue(relaunched.staticTexts[eventTitle].waitForExistence(timeout: 10))
    }

    @MainActor
    private func deleteEvent(in app: XCUIApplication) throws {
        let row = app.staticTexts[eventTitle]
        try XCTSkipUnless(row.waitForExistence(timeout: 10), "Grant calendar access to seed sample data first")
        row.tap()
        let deleteButton = app.buttons["Delete Event"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()
    }

    @MainActor
    private func launch(seeding: Bool, toastSeconds: Int? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-Calendar.ViewMode", "list", "-FolioSkipOnboarding"
        ] + (seeding ? ["-SeedSampleCalendarData"] : [])
            + (toastSeconds.map { ["-UndoToastSeconds", "\($0)"] } ?? [])
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
