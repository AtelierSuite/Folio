import Foundation

public struct ReminderDraft: Sendable, Hashable {
    public var title: String
    public var listIdentifier: String
    public var dueDate: Date?
    public var hasDueTime: Bool
    public var priority: ReminderPriority
    public var recurrence: ReminderRecurrence?
    public var alarms: [ReminderAlarm]
    public var url: URL?
    public var notes: String

    public init(
        title: String = "",
        listIdentifier: String,
        dueDate: Date? = nil,
        hasDueTime: Bool = false,
        priority: ReminderPriority = .none,
        recurrence: ReminderRecurrence? = nil,
        alarms: [ReminderAlarm] = [],
        url: URL? = nil,
        notes: String = ""
    ) {
        self.title = title
        self.listIdentifier = listIdentifier
        self.dueDate = dueDate
        self.hasDueTime = hasDueTime
        self.priority = priority
        self.recurrence = recurrence
        self.alarms = alarms
        self.url = url
        self.notes = notes
    }

    public init(_ reminder: ReminderItem) {
        self.init(
            title: reminder.title,
            listIdentifier: reminder.listIdentifier,
            dueDate: reminder.dueDate,
            hasDueTime: reminder.dueDate != nil && reminder.hasDueTime,
            priority: ReminderPriority(eventKitPriority: reminder.priority),
            recurrence: reminder.recurrence,
            alarms: reminder.alarms.map { alarm in
                if reminder.hasDueTime, case .absolute(let date) = alarm, date == reminder.dueDate {
                    return .relative(0)
                }
                return alarm
            },
            url: reminder.url,
            notes: reminder.notes ?? ""
        )
    }

    public var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isValid: Bool {
        !trimmedTitle.isEmpty && !listIdentifier.isEmpty
    }

    public var canRepeat: Bool {
        dueDate != nil
    }

    public var canUseRelativeAlarms: Bool {
        dueDate != nil && hasDueTime
    }
}
