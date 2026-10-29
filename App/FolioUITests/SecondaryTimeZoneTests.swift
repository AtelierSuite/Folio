import XCTest

final class SecondaryTimeZoneTests: XCTestCase {
    @MainActor
    func testPickingASecondaryTimeZoneAddsAColumnToTheDayView() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Calendar.ViewMode", "day", "-FolioSkipOnboarding", "-AppleLanguages", "(en)"]
        app.launch()

        app.tabBars.buttons.element(boundBy: 2).tap()
        let toggle = app.switches.matching(identifier: "SecondaryTimeZoneToggle").firstMatch
        scrollIntoView(toggle, in: app)
        setToggle(toggle, isOn: true)

        let link = app.buttons["SecondaryTimeZoneLink"]
        scrollIntoView(link, in: app)
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

        let event = app.buttons["Standup"].firstMatch
        if event.waitForExistence(timeout: 5) {
            event.tap()
            let secondaryTime = app.descendants(matching: .any)["EventDetailSecondaryTime"].firstMatch
            XCTAssertTrue(secondaryTime.waitForExistence(timeout: 5))
            XCTAssertTrue(secondaryTime.label.contains("Reykjavik"))
            attachScreenshot(named: "SecondaryTimeZoneEventDetail")
            app.buttons["Done"].firstMatch.tap()
        }

        app.tabBars.buttons.element(boundBy: 2).tap()
        scrollIntoView(toggle, in: app)
        setToggle(toggle, isOn: false)
        app.tabBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(header.waitForNonExistence(timeout: 5))
    }

    @MainActor
    private func setToggle(_ toggle: XCUIElement, isOn: Bool) {
        let expectedValue = isOn ? "1" : "0"
        var attempts = 0
        while toggle.value as? String != expectedValue && attempts < 3 {
            toggle.switches.firstMatch.tap()
            let predicate = NSPredicate(format: "value == %@", expectedValue)
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: toggle)
            _ = XCTWaiter.wait(for: [expectation], timeout: 2)
            attempts += 1
        }
        XCTAssertEqual(toggle.value as? String, expectedValue)
    }

    @MainActor
    private func scrollIntoView(_ element: XCUIElement, in app: XCUIApplication) {
        let top = app.navigationBars.firstMatch.frame.maxY
        let bottom = app.tabBars.firstMatch.frame.minY
        for _ in 0..<8 {
            if element.exists && element.frame.minY < top {
                app.swipeDown()
            } else if !element.exists || element.frame.maxY > bottom {
                app.swipeUp()
            } else {
                return
            }
        }
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
