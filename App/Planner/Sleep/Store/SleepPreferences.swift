import Foundation

/// Sleep settings live in the app's own defaults, never in the App Group or iCloud.
public struct SleepPreferences: Sendable {
    public static let showsOnTimelineKey = "Sleep.ShowsOnTimeline"
    public static let preferredSourceKey = "Sleep.PreferredSource"

    private let suiteName: String?

    public init(suiteName: String? = nil) {
        self.suiteName = suiteName
    }

    private var defaults: UserDefaults {
        suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    public var showsOnTimeline: Bool {
        get { defaults.bool(forKey: Self.showsOnTimelineKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.showsOnTimelineKey) }
    }

    public var preferredSourceIdentifier: String? {
        get { defaults.string(forKey: Self.preferredSourceKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.preferredSourceKey) }
    }
}
