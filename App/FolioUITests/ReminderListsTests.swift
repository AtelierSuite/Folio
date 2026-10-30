import XCTest

final class ReminderListsTests: XCTestCase {
    @MainActor
    func testListsTabShowsRemindersOfSelectedList() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FolioSkipOnboarding", "-AppleLanguages", "(en)"]
        app.launch()

        let listsTab = app.buttons["Lists"].firstMatch
        XCTAssertTrue(listsTab.waitForExistence(timeout: 10))
        listsTab.tap()

        let sampleList = app.descendants(matching: .any)["ReminderList.Folio Samples"].firstMatch
        try XCTSkipUnless(sampleList.waitForExistence(timeout: 5), "Seed sample data first")
        attachScreenshot(named: "ReminderLists")

        sampleList.tap()
        let undated = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Plan weekend trip")).firstMatch
        XCTAssertTrue(undated.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["ReminderListNewReminder"].exists)
        attachScreenshot(named: "ReminderListDetail")
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
