import Foundation

public enum OverdueReminderPolicy: String, CaseIterable, Sendable, Identifiable {
    case carryForward
    case keepOnDueDate

    public var id: Self { self }
}
