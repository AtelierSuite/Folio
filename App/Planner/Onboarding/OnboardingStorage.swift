import Foundation

public struct OnboardingStorage: @unchecked Sendable {
    public static let hasCompletedOnboardingKey = "Onboarding.HasCompleted"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Self.hasCompletedOnboardingKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.hasCompletedOnboardingKey) }
    }
}
