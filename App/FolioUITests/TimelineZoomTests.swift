import XCTest

/// Pinching out with XCUITest puts the touches on the corners of the timeline, where the floating
/// tab bar is on iPhone, so these tests pinch in and zoom out with the zoom controls.
final class TimelineZoomTests: XCTestCase {
    @MainActor
    func testPinchingInLeavesTheWholeDayFit() throws {
        let app = launch(arguments: ["-Calendar.Timeline.Zoom.day", "0"])
        openZoomControls(in: app)
        XCTAssertTrue(app.buttons["Fit Whole Day"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Fit Whole Day"].isEnabled)
        XCTAssertFalse(app.buttons["Zoom Out"].isEnabled)
        dismissMenu(in: app)

        timeline(in: app).pinch(withScale: 3, velocity: 2)

        openZoomControls(in: app)
        XCTAssertTrue(app.buttons["Fit Whole Day"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Fit Whole Day"].isEnabled)
        XCTAssertTrue(app.buttons["Zoom Out"].isEnabled)
    }

    @MainActor
    func testFittingTheWholeDayIsRemembered() throws {
        let app = launch(arguments: [])
        openZoomControls(in: app)
        let fitButton = app.buttons["Fit Whole Day"]
        XCTAssertTrue(fitButton.waitForExistence(timeout: 5))
        if !fitButton.isEnabled {
            app.buttons["Zoom In"].tap()
            openZoomControls(in: app)
        }
        XCTAssertTrue(fitButton.waitForExistence(timeout: 5))
        XCTAssertTrue(fitButton.isEnabled)
        fitButton.tap()
        openZoomControls(in: app)
        XCTAssertTrue(fitButton.waitForExistence(timeout: 5))
        XCTAssertFalse(fitButton.isEnabled)
        XCTAssertFalse(app.buttons["Zoom Out"].isEnabled)

        app.terminate()
        app.launch()
        openZoomControls(in: app)
        XCTAssertTrue(fitButton.waitForExistence(timeout: 5))
        XCTAssertFalse(fitButton.isEnabled)
        app.buttons["Zoom In"].tap()
        openZoomControls(in: app)
        XCTAssertTrue(fitButton.waitForExistence(timeout: 5))
        XCTAssertTrue(fitButton.isEnabled)
    }

    private let baseArguments = [
        "-AppleLanguages", "(en)", "-AppleLocale", "en_US", "-Calendar.ViewMode", "day", "-FolioSkipOnboarding"
    ]

    @MainActor
    private func launch(arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = baseArguments + arguments
        app.launch()
        return app
    }

    @MainActor
    private func timeline(in app: XCUIApplication) -> XCUIElement {
        let timeline = app.descendants(matching: .any)["TimelineScrollView"].firstMatch
        XCTAssertTrue(timeline.waitForExistence(timeout: 10))
        return timeline
    }

    /// On iPhone the zoom controls are in the toolbar's overflow menu.
    @MainActor
    private func openZoomControls(in app: XCUIApplication) {
        let overflow = app.buttons["OverflowBarButtonItem"].firstMatch
        XCTAssertTrue(overflow.waitForExistence(timeout: 10))
        overflow.tap()
    }

    @MainActor
    private func dismissMenu(in app: XCUIApplication) {
        app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        _ = app.buttons["Fit Whole Day"].waitForNonExistence(timeout: 5)
    }
}
