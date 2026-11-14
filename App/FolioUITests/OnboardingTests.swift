import XCTest

final class OnboardingTests: XCTestCase {
    @MainActor
    func testGetStartedShowsFeatureSetupAndEveryStepLeadsToThePermissionRequest() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Onboarding.HasCompleted", "NO", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        let welcomeTitle = app.staticTexts["OnboardingTitle"]
        XCTAssertTrue(welcomeTitle.waitForExistence(timeout: 10))
        XCTAssertEqual(welcomeTitle.label, "Welcome to Folio")
        attachScreenshot(named: "OnboardingWelcome")
        app.buttons["OnboardingGetStarted"].tap()

        let setupTitle = app.staticTexts["OnboardingSetupTitle"]
        XCTAssertTrue(setupTitle.waitForExistence(timeout: 5))
        attachScreenshot(named: "OnboardingSetup")

        XCTAssertFalse(app.buttons["OnboardingSkip"].exists)
        let setUp = app.buttons["OnboardingSetUp"]
        for _ in 0..<OnboardingTests.maximumSetupSteps where setupTitle.waitForExistence(timeout: 3) {
            let shownTitle = setupTitle.label
            setUp.tap()
            declinePermissionRequest(in: app)
            let nextPage = NSPredicate(format: "exists == false OR label != %@", shownTitle)
            let pageChanged = expectation(for: nextPage, evaluatedWith: setupTitle)
            XCTAssertEqual(XCTWaiter().wait(for: [pageChanged], timeout: 10), .completed)
        }
        XCTAssertTrue(setupTitle.waitForNonExistence(timeout: 5))
    }

    private static let maximumSetupSteps = 8
    private static let declineLabels = ["Don’t Allow", "許可しない"]

    @MainActor
    private func declinePermissionRequest(in app: XCUIApplication) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let declineLabel = NSPredicate(format: "label IN %@", Self.declineLabels)
        let systemDecline = springboard.alerts.buttons.matching(declineLabel).firstMatch
        let healthDecline = app.staticTexts.matching(declineLabel).firstMatch
        if systemDecline.waitForExistence(timeout: 3) {
            systemDecline.tap()
        } else if healthDecline.exists {
            app.tables.firstMatch.swipeUp()
            healthDecline.tap()
        }
    }

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
