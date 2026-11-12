import XCTest

final class OnboardingTests: XCTestCase {
    @MainActor
    func testGetStartedShowsFeatureSetupAndSkippingEveryStepDismissesOnboarding() throws {
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

        let skip = app.buttons["OnboardingSkip"]
        for _ in 0..<OnboardingTests.maximumSetupSteps where skip.waitForExistence(timeout: 3) {
            skip.tap()
            _ = setupTitle.waitForNonExistence(timeout: 1)
        }
        XCTAssertTrue(setupTitle.waitForNonExistence(timeout: 5))
    }

    private static let maximumSetupSteps = 8

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
