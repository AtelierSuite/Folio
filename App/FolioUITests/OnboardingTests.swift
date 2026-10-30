import XCTest

final class OnboardingTests: XCTestCase {
    @MainActor
    func testOnboardingAppearsAndGetStartedDismissesIt() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-Onboarding.HasCompleted", "NO", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        let title = app.staticTexts["OnboardingTitle"]
        XCTAssertTrue(title.waitForExistence(timeout: 10))
        XCTAssertEqual(title.label, "Welcome to Folio")

        let getStarted = app.buttons["OnboardingContinue"]
        XCTAssertTrue(getStarted.exists)
        getStarted.tap()

        let dismissed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: title)
        XCTAssertEqual(XCTWaiter.wait(for: [dismissed], timeout: 5), .completed)
    }
}
