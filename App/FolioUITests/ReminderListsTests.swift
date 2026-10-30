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
    func testCreatingListOpensIt() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-FolioSkipOnboarding", "-AppleLanguages", "(en)"]
        app.launch()

        let listsTab = app.buttons["Lists"].firstMatch
        XCTAssertTrue(listsTab.waitForExistence(timeout: 10))
        listsTab.tap()

        let newListButton = app.buttons["NewReminderList"].firstMatch
        XCTAssertTrue(newListButton.waitForExistence(timeout: 5))
        try XCTSkipUnless(newListButton.isEnabled, "Grant Reminders access first")
        newListButton.tap()

        let nameField = app.textFields["NewListName"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        let createButton = app.buttons["NewListCreate"]
        XCTAssertFalse(createButton.isEnabled)
        let title = "Groceries \(Int.random(in: 100...999))"
        nameField.tap()
        nameField.typeText(title)
        app.buttons["Color 5"].tap()
        attachScreenshot(named: "NewList")

        createButton.tap()
        XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5))
        attachScreenshot(named: "NewListCreated")

        app.navigationBars[title].buttons.firstMatch.tap()
        XCTAssertTrue(app.descendants(matching: .any)["ReminderList.\(title)"].firstMatch.waitForExistence(timeout: 5))
        attachScreenshot(named: "NewListInSidebar")
    }

    @MainActor
    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
