import XCTest

final class OnboardingTests: XCTestCase {
    @MainActor
    func testGetStartedShowsPermissionsAndContinueDismissesOnboarding() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Onboarding.HasCompleted", "NO", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        let welcomeTitle = app.staticTexts["OnboardingTitle"]
        XCTAssertTrue(welcomeTitle.waitForExistence(timeout: 10))
        XCTAssertEqual(welcomeTitle.label, "Welcome to Folio")
        attachScreenshot(named: "OnboardingWelcome")
        app.buttons["OnboardingGetStarted"].tap()

        let permissionsTitle = app.staticTexts["OnboardingPermissionsTitle"]
        XCTAssertTrue(permissionsTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["OnboardingPermission.calendar"].exists)
        attachScreenshot(named: "OnboardingPermissions")
        app.buttons["OnboardingContinue"].tap()

        let dismissed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: permissionsTitle
        )
        XCTAssertEqual(XCTWaiter.wait(for: [dismissed], timeout: 5), .completed)
    }

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
