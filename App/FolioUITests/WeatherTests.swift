import XCTest

final class WeatherTests: XCTestCase {
    @MainActor
    func testSampleWeatherShowsAndCanBeTurnedOffFromWeatherSettings() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Calendar.ViewMode", "week", "-FolioSkipOnboarding", "-FolioSampleWeather"]
        app.launch()

        let dayHeaderWeather = app.descendants(matching: .any)["DayHeaderWeather"].firstMatch
        XCTAssertTrue(dayHeaderWeather.waitForExistence(timeout: 10))
        XCTAssertFalse(app.links["WeatherAttributionLink"].exists)
        attachScreenshot(named: "WeatherWeek")

        app.tabBars.buttons.element(boundBy: 2).tap()
        app.openSettingsCategory("weather")
        let toggle = app.switches.matching(identifier: "WeatherToggle").firstMatch
        scrollUntilHittable(toggle, in: app)
        XCTAssertTrue(app.buttons["WeatherLocationLink"].exists)
        XCTAssertTrue(app.links["WeatherAttributionLink"].waitForExistence(timeout: 5))
        attachScreenshot(named: "WeatherSettings")
        setToggle(toggle, isOn: false)
        XCTAssertTrue(app.buttons["WeatherLocationLink"].waitForNonExistence(timeout: 5))

        app.tabBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(dayHeaderWeather.waitForNonExistence(timeout: 5))
    }

    @MainActor
    private func scrollUntilHittable(_ element: XCUIElement, in app: XCUIApplication) {
        var attempts = 0
        while !(element.waitForExistence(timeout: 2) && element.isHittable) && attempts < 6 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(element.exists)
    }

    @MainActor
    private func setToggle(_ toggle: XCUIElement, isOn: Bool) {
        let expectedValue = isOn ? "1" : "0"
        let hasExpectedValue = NSPredicate(format: "value == %@", expectedValue)
        for _ in 0..<3 where toggle.value as? String != expectedValue {
            toggle.switches.firstMatch.tap()
            let expectation = XCTNSPredicateExpectation(predicate: hasExpectedValue, object: toggle)
            _ = XCTWaiter.wait(for: [expectation], timeout: 2)
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
