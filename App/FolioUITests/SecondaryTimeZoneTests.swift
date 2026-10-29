import XCTest

final class SecondaryTimeZoneTests: XCTestCase {
    @MainActor
    func testPickingASecondaryTimeZoneAddsAColumnToTheDayView() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Calendar.ViewMode", "day", "-FolioSkipOnboarding", "-AppleLanguages", "(en)"]
        app.launch()

        app.tabBars.buttons.element(boundBy: 2).tap()
        let toggle = app.switches.matching(identifier: "SecondaryTimeZoneToggle").firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        app.swipeUp()
        setToggle(toggle, isOn: true)

        let link = app.buttons["SecondaryTimeZoneLink"]
        app.swipeUp()
        link.tap()
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Reykjavik")
        let option = app.buttons["TimeZoneOption.Atlantic/Reykjavik"]
        XCTAssertTrue(option.waitForExistence(timeout: 5))
        attachScreenshot(named: "SecondaryTimeZonePicker")
        option.tap()
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        attachScreenshot(named: "SecondaryTimeZoneSettings")

        app.tabBars.buttons.element(boundBy: 0).tap()
        let header = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@", "Second time zone: Reykjavik")).firstMatch
        XCTAssertTrue(header.waitForExistence(timeout: 5))
        attachScreenshot(named: "SecondaryTimeZoneDay")

        app.tabBars.buttons.element(boundBy: 2).tap()
        app.swipeUp()
        setToggle(toggle, isOn: false)
        app.tabBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(header.waitForNonExistence(timeout: 5))
    }

    @MainActor
    private func setToggle(_ toggle: XCUIElement, isOn: Bool) {
        let expectedValue = isOn ? "1" : "0"
        if toggle.value as? String != expectedValue {
            toggle.switches.firstMatch.tap()
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
