import Foundation
import Testing
@testable import Planner

struct OnboardingStorageTests {
    @Test func onboardingIsShownUntilCompleted() throws {
        let suiteName = "OnboardingStorageTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let storage = OnboardingStorage(defaults: defaults)

        #expect(!storage.hasCompletedOnboarding)
        storage.hasCompletedOnboarding = true
        #expect(OnboardingStorage(defaults: defaults).hasCompletedOnboarding)
    }
}
