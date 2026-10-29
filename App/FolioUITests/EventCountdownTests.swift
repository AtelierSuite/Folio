import XCTest

final class EventCountdownTests: XCTestCase {
    @MainActor
    func testCountdownStartsAndStopsFromEventDetail() throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-FolioSkipOnboarding", "-SeedCountdownEvent"
        ]
        app.launch()
        let event = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Folio Countdown")).firstMatch
        try XCTSkipUnless(event.waitForExistence(timeout: 10), "Grant calendar access; the event is 30 minutes from now")
        event.tap()

        let button = app.buttons["EventCountdownButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 10))
        XCTAssertTrue(button.isEnabled)
        XCTAssertEqual(button.label, "Start Countdown")
        button.tap()
        XCTAssertTrue(button.wait(for: \.label, toEqual: "Stop Countdown", timeout: 5))
        button.tap()
        XCTAssertTrue(button.wait(for: \.label, toEqual: "Start Countdown", timeout: 5))
    }
}
