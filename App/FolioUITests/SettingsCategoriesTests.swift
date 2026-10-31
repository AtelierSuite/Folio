import XCTest

final class SettingsCategoriesTests: XCTestCase {
    private static let categoryContents: [(category: String, identifier: String)] = [
        ("general", "EventTapBehaviorPicker"),
        ("calendars", "CalendarVisibilityLink"),
        ("notes", "LinkedNotes.WritesLinkToEvent"),
        ("search", "Search.Settings.MonthsBack"),
        ("weather", "WeatherToggle")
    ]

    @MainActor
    func testEveryCategoryOpensItsSettings() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FolioSkipOnboarding", "-AppleLanguages", "(en)"]
        app.launch()

        app.buttons["Settings"].firstMatch.tap()
        XCTAssertTrue(app.buttons["SettingsCategory.general"].waitForExistence(timeout: 10))
        attachScreenshot(named: "SettingsRoot")

        for (category, identifier) in Self.categoryContents {
            app.openSettingsCategory(category)
            let content = app.descendants(matching: .any)[identifier].firstMatch
            XCTAssertTrue(content.waitForExistence(timeout: 5), "\(category) is missing \(identifier)")
            attachScreenshot(named: "Settings-\(category)")
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }

        app.buttons["NotificationSettingsLink"].tap()
        XCTAssertTrue(app.switches["NotificationsEnabledToggle"].waitForExistence(timeout: 5))
        attachScreenshot(named: "Settings-notifications")
    }

    @MainActor
    func testSourceCodeLinkIsShown() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FolioSkipOnboarding", "-AppleLanguages", "(en)"]
        app.launch()

        app.buttons["Settings"].firstMatch.tap()
        XCTAssertTrue(app.buttons["SettingsCategory.general"].waitForExistence(timeout: 10))
        let link = app.links["SourceCodeLink"]
        for _ in 0..<6 where !link.exists {
            app.swipeUp()
        }
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        XCTAssertTrue(link.label.contains("AtelierSuite/Folio"))
        attachScreenshot(named: "Settings-SourceCode")
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
