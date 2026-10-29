import XCTest

final class LaunchTests: XCTestCase {
    @MainActor
    func testLaunchShowsCalendar() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-FolioSkipOnboarding")
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }
}
