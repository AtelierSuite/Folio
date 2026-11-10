import Foundation

public struct CalendarVisibilityStorage: @unchecked Sendable {
    public static let hiddenCalendarIdentifiersKey = "Calendar.HiddenCalendarIdentifiers"
    public static let hidesDeclinedEventsKey = "Calendar.HidesDeclinedEvents"

    public static let hiddenInvitationIdentifiersKey = "Calendar.HiddenInvitationIdentifiers"

    public static let defaultEventCalendarIdentifierKey = "Calendar.DefaultEventCalendarIdentifier"
    public static let defaultReminderListIdentifierKey = "Calendar.DefaultReminderListIdentifier"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = AppGroup.userDefaults) {
        self.defaults = defaults
    }

    public var hiddenCalendarIdentifiers: Set<String> {
        get { Set(defaults.stringArray(forKey: Self.hiddenCalendarIdentifiersKey) ?? []) }
        nonmutating set { defaults.set(newValue.sorted(), forKey: Self.hiddenCalendarIdentifiersKey) }
    }

    public var hiddenInvitationIdentifiers: Set<String> {
        get { Set(defaults.stringArray(forKey: Self.hiddenInvitationIdentifiersKey) ?? []) }
        nonmutating set { defaults.set(newValue.sorted(), forKey: Self.hiddenInvitationIdentifiersKey) }
    }

    public var hidesDeclinedEvents: Bool {
        get { defaults.bool(forKey: Self.hidesDeclinedEventsKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.hidesDeclinedEventsKey) }
    }

    public var defaultEventCalendarIdentifier: String? {
        get { defaults.string(forKey: Self.defaultEventCalendarIdentifierKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.defaultEventCalendarIdentifierKey) }
    }

    public var defaultReminderListIdentifier: String? {
        get { defaults.string(forKey: Self.defaultReminderListIdentifierKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.defaultReminderListIdentifierKey) }
    }
}
