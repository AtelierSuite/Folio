import XCTest

final class WeatherTests: XCTestCase {
    @MainActor
    func testSampleWeatherShowsWithAttributionAndCanBeTurnedOff() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Calendar.ViewMode", "week", "-FolioSkipOnboarding", "-FolioSampleWeather"]
        app.launch()

        let attribution = app.links["WeatherAttributionLink"]
        XCTAssertTrue(attribution.waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["DayHeaderWeather"].firstMatch.exists)
        attachScreenshot(named: "WeatherWeek")

        app.tabBars.buttons.element(boundBy: 2).tap()
        let toggle = app.switches.matching(identifier: "WeatherToggle").firstMatch
        scrollUntilHittable(toggle, in: app)
        XCTAssertTrue(app.buttons["WeatherLocationLink"].exists)
        attachScreenshot(named: "WeatherSettings")
        setToggle(toggle, isOn: false)
        XCTAssertTrue(app.buttons["WeatherLocationLink"].waitForNonExistence(timeout: 5))

        app.tabBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(attribution.waitForNonExistence(timeout: 5))
    }

    @MainActor
    private func scrollUntilHittable(_ element: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(element.waitForExistence(timeout: 5))
        var attempts = 0
        while !element.isHittable && attempts < 5 {
            app.swipeUp()
            attempts += 1
        }
    }

    @MainActor
    private func setToggle(_ toggle: XCUIElement, isOn: Bool) {
        let expectedValue = isOn ? "1" : "0"
        let hasExpectedValue = NSPredicate(format: "value == %@", expectedValue)
        for _ in 0..<3 where toggle.value as? String != expectedValue {
            toggle.switches.firstMatch.tap()
            _ = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: hasExpectedValue, object: toggle)], timeout: 2)
        }
        XCTAssertEqual(toggle.value as? String, expectedValue)
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
