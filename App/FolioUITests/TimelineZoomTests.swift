import XCTest

/// Pinching out with XCUITest puts the touches on the corners of the timeline, where the floating
/// tab bar is on iPhone, so these tests pinch in and zoom out with the zoom menu.
final class TimelineZoomTests: XCTestCase {
    @MainActor
    func testPinchingInLeavesTheWholeDayFit() throws {
        let app = launch(arguments: ["-Calendar.Timeline.Zoom.day", "0"])
        let zoomMenu = app.buttons["TimelineZoomMenu"]
        XCTAssertTrue(zoomMenu.waitForExistence(timeout: 10))
        zoomMenu.tap()
        XCTAssertTrue(app.buttons["Fit Whole Day"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Fit Whole Day"].isEnabled)
        XCTAssertFalse(app.buttons["Zoom Out"].isEnabled)
        dismissMenu(in: app)

        timeline(in: app).pinch(withScale: 3, velocity: 2)

        zoomMenu.tap()
        XCTAssertTrue(app.buttons["Fit Whole Day"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Fit Whole Day"].isEnabled)
        XCTAssertTrue(app.buttons["Zoom Out"].isEnabled)
    }

    @MainActor
    func testFittingTheWholeDayIsRemembered() throws {
        let app = launch(arguments: [])
        let zoomMenu = app.buttons["TimelineZoomMenu"]
        XCTAssertTrue(zoomMenu.waitForExistence(timeout: 10))
        zoomMenu.tap()
        let fitButton = app.buttons["Fit Whole Day"]
        XCTAssertTrue(fitButton.waitForExistence(timeout: 5))
        if !fitButton.isEnabled {
            app.buttons["Zoom In"].tap()
        }
        XCTAssertTrue(fitButton.isEnabled)
        fitButton.tap()
        XCTAssertFalse(fitButton.isEnabled)
        XCTAssertFalse(app.buttons["Zoom Out"].isEnabled)

        app.terminate()
        app.launch()
        XCTAssertTrue(zoomMenu.waitForExistence(timeout: 10))
        zoomMenu.tap()
        XCTAssertTrue(app.buttons["Fit Whole Day"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Fit Whole Day"].isEnabled)
        app.buttons["Zoom In"].tap()
        XCTAssertTrue(app.buttons["Fit Whole Day"].isEnabled)
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

    @MainActor
    private func dismissMenu(in app: XCUIApplication) {
        app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        _ = app.buttons["Fit Whole Day"].waitForNonExistence(timeout: 5)
    }
}
