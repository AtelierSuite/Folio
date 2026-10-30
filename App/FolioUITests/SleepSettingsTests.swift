import XCTest

final class SleepSettingsTests: XCTestCase {
    @MainActor
    func testSleepToggleIsOfferedOnIPhoneOnly() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FolioSkipOnboarding"]
        app.launch()

        app.tabBars.buttons.element(boundBy: 2).tap()
        let toggle = app.switches["SleepTimelineToggle"]
        #if os(iOS)
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        #else
        let isPhone = false
        #endif
        if isPhone {
            app.openSettingsCategory("sleep")
            for _ in 0..<3 where !toggle.exists {
                app.swipeUp()
            }
        } else {
            XCTAssertFalse(app.buttons["SettingsCategory.sleep"].waitForExistence(timeout: 3))
        }
        XCTAssertEqual(toggle.waitForExistence(timeout: 5), isPhone)
    }
}
