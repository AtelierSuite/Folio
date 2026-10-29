import AppIntents
import Foundation

public struct ReminderEntity: AppEntity, Identifiable, Sendable {
    public static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("ReminderEntity.TypeName", table: "AppIntents", bundle: #bundle)
    )
    public static let defaultQuery = ReminderEntityQuery()

    /// The reminder's `CalendarItemReference.storageKey`, which survives sync.
    public let id: String
    public let reference: CalendarItemReference
    public let listIdentifier: String
    public let hasDueTime: Bool
    public let isReadOnly: Bool

    @Property(title: LocalizedStringResource("ReminderEntity.Title", table: "AppIntents", bundle: #bundle))
    public var title: String

    @Property(title: LocalizedStringResource("ReminderEntity.DueDate", table: "AppIntents", bundle: #bundle))
    public var dueDate: Date?

    @Property(title: LocalizedStringResource("ReminderEntity.IsCompleted", table: "AppIntents", bundle: #bundle))
    public var isCompleted: Bool

    @Property(title: LocalizedStringResource("ReminderEntity.Notes", table: "AppIntents", bundle: #bundle))
    public var notes: String?

    public init(_ reminder: ReminderItem) {
        id = reminder.reference.storageKey
        reference = reminder.reference
        listIdentifier = reminder.listIdentifier
        hasDueTime = reminder.hasDueTime
        isReadOnly = reminder.isReadOnly
        title = reminder.title
        dueDate = reminder.dueDate
        isCompleted = reminder.isCompleted
        notes = reminder.notes
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: dueText.map { "\($0)" },
            image: DisplayRepresentation.Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
        )
    }

    private var dueText: String? {
        guard let dueDate else { return nil }
        return hasDueTime ? IntentDateText.time(dueDate) : IntentDateText.day(dueDate)
    }
}
