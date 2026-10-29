import Foundation

public struct ReminderItem: Identifiable, Sendable, Hashable {
    public let reference: CalendarItemReference
    public let listIdentifier: String
    public let title: String
    public let notes: String?
    public let dueDate: Date?
    public let hasDueTime: Bool
    public let isCompleted: Bool
    public let completionDate: Date?
    public let priority: Int
    public let color: PlannerColor
    public let isRecurring: Bool
    public let isReadOnly: Bool

    public init(
        reference: CalendarItemReference,
        listIdentifier: String,
        title: String,
        notes: String? = nil,
        dueDate: Date? = nil,
        hasDueTime: Bool = false,
        isCompleted: Bool = false,
        completionDate: Date? = nil,
        priority: Int = 0,
        color: PlannerColor = .gray,
        isRecurring: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.reference = reference
        self.listIdentifier = listIdentifier
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.hasDueTime = hasDueTime
        self.isCompleted = isCompleted
        self.completionDate = completionDate
        self.priority = priority
        self.color = color
        self.isRecurring = isRecurring
        self.isReadOnly = isReadOnly
    }

    public var id: String {
        reference.localIdentifier
    }

    public func isDue(in interval: DateInterval) -> Bool {
        guard let dueDate else { return false }
        return interval.start <= dueDate && dueDate < interval.end
    }
}
