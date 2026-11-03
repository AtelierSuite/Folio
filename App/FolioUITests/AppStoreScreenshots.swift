import XCTest

/// Seeds and captures the App Store screenshots.
///
/// Driven by `Assets/App Store/capture.sh`, which says where to write through `SCREENSHOT_DIR` and which language to
/// use through `SCREENSHOT_LANGUAGE`. Without them the test skips, so it stays out of an ordinary test run.
final class AppStoreScreenshots: XCTestCase {
    private enum Stage: String {
        case week, lists, notes, alarms, notifications, countdown
    }

    private struct Shot {
        let name: String
        let stage: Stage
    }

    private static let shots = [
        Shot(name: "01-week", stage: .week),
        Shot(name: "02-lists", stage: .lists),
        Shot(name: "03-notes", stage: .notes),
        Shot(name: "04-alarms", stage: .alarms),
        Shot(name: "05-notifications", stage: .notifications)
    ]

    private var directory: URL!
    private var language = "en"
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        let environment = ProcessInfo.processInfo.environment
        guard let path = environment["SCREENSHOT_DIR"], !path.isEmpty else {
            throw XCTSkip("run through Assets/App Store/capture.sh")
        }
        directory = URL(fileURLWithPath: path)
        language = environment["SCREENSHOT_LANGUAGE"] ?? "en"
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    /// Seeds the samples, then captures every shot but the countdown.
    @MainActor
    func testScreens() throws {
        seed()
        for shot in Self.shots {
            launch(shot.stage)
            try stage(shot.stage)
            try capture(shot.name)
        }
    }

    /// Run after `testScreens`, once `capture.sh` has set the status bar to the real time: the Live Activity shows
    /// when the event starts, and the Lock Screen clock should agree with it.
    @MainActor
    func testCountdown() throws {
        launch(.countdown)
        try stage(.countdown)
        try capture("06-countdown")
    }

    // MARK: - Steps

    /// The first launch writes the samples.
    @MainActor
    private func seed() {
        launch(.week, extraArguments: ["-FolioScreenshotSamples"])
        XCTAssertTrue(app.descendants(matching: .any)["DayHeaderWeather"].firstMatch.waitForExistence(timeout: 20))
        // Longer than seeding takes after the calendar first shows.
        Thread.sleep(forTimeInterval: 10)
        app.terminate()
    }

    @MainActor
    private func launch(_ stage: Stage, extraArguments: [String] = []) {
        app = XCUIApplication()
        let locale = language == "ja" ? "ja_JP" : "en_US"
        app.launchArguments += [
            "-AppleLanguages", "(\(language))", "-AppleLocale", locale,
            "-FolioSkipOnboarding", "-FolioSampleWeather", "-FolioSampleSleep", "-FolioScreenshotStage", stage.rawValue
        ] + extraArguments
        app.launch()
    }

    @MainActor
    private func stage(_ stage: Stage) throws {
        switch stage {
        case .notifications:
            app.openSettingsCategory("eventNotifications")
        case .countdown:
            // Long enough for the Live Activity to start, then shown on the Lock Screen.
            Thread.sleep(forTimeInterval: 4)
            XCUIDevice.shared.perform(NSSelectorFromString("pressLockButton"))
            Thread.sleep(forTimeInterval: 2)
            XCUIDevice.shared.perform(NSSelectorFromString("pressLockButton"))
            allowLiveActivities()
        case .week, .lists, .notes, .alarms:
            break
        }
        // Let the samples load and any navigation finish animating in.
        Thread.sleep(forTimeInterval: 4)
    }

    @MainActor
    private func capture(_ name: String) throws {
        let file = directory.appendingPathComponent("\(name).png")
        try XCUIScreen.main.screenshot().pngRepresentation.write(to: file)
    }

    /// The first Live Activity asks on the Lock Screen whether to keep showing them.
    @MainActor
    private func allowLiveActivities() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.buttons[language == "ja" ? "許可" : "Allow"].firstMatch
        if allow.waitForExistence(timeout: 5) {
            allow.tap()
        } else {
            print(springboard.debugDescription)
        }
    }
}
