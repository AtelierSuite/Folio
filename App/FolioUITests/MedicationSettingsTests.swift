import XCTest

final class MedicationSettingsTests: XCTestCase {
    @MainActor
    func testTurningOnShowsSharedMedications() throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "-FolioSkipOnboarding", "-FolioSampleMedications", "-Medications.ShowsOnTimeline", "NO",
            "-AppleLanguages", "(en)"
        ]
        app.launch()

        app.buttons["Settings"].firstMatch.tap()
        app.openSettingsCategory("medications")

        let toggle = app.switches["MedicationTimelineToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.switches.firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Vitamin D"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Cetirizine"].exists)
    }
}
