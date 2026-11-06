import XCTest

final class GalleryControlsUITests: XCTestCase {
    @MainActor private var app = XCUIApplication()

    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        app.launch()
    }

    @MainActor
    private func saveScreenshot(_ name: String) throws {
        guard let output = ProcessInfo.processInfo.environment["LAB_OUTPUT"] else { return }
        let url = URL(filePath: output).appending(path: "\(name).png")
        try XCUIScreen.main.screenshot().pngRepresentation.write(to: url)
    }

    @MainActor
    private func scroll(toText text: String) -> XCUIElement {
        let element = app.staticTexts[text].firstMatch
        for _ in 0..<14 where !element.isHittable {
            app.swipeUp()
        }
        return element
    }

    @MainActor
    func testGalleryStartsOnTheBusyAfternoon() throws {
        XCTAssertTrue(app.staticTexts["13:53"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Leave in"].firstMatch.exists)
        try saveScreenshot("device-busy")
    }

    @MainActor
    func testEmptyScenarioSwitchesEveryWidgetToItsEmptyState() throws {
        app.buttons["Empty"].tap()
        XCTAssertTrue(app.staticTexts["Nowhere to be today"].firstMatch.waitForExistence(timeout: 5))
        try saveScreenshot("device-empty")
    }

    @MainActor
    func testSliderMovesDayShiftIntoTheEvening() throws {
        app.sliders.firstMatch.adjust(toNormalizedSliderPosition: 0.9)
        XCTAssertFalse(app.staticTexts["13:53"].exists)
        let windDown = scroll(toText: "Wind down")
        XCTAssertTrue(windDown.exists)
        try saveScreenshot("device-evening")
    }

    @MainActor
    func testLastIdeaIsReachable() throws {
        XCTAssertTrue(scroll(toText: "10. Dose Rail").exists)
        try saveScreenshot("device-last-idea")
    }
}
