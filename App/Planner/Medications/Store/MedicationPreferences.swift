import Foundation

/// Medication settings live in the app's own defaults, never in the App Group or iCloud.
public struct MedicationPreferences: Sendable {
    public static let showsOnTimelineKey = "Medications.ShowsOnTimeline"
    public static let sendsRemindersKey = "Medications.SendsReminders"

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

    public var sendsReminders: Bool {
        get { defaults.bool(forKey: Self.sendsRemindersKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.sendsRemindersKey) }
    }
}
