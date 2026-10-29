import Foundation

/// An item hidden from every view while its delete waits for the undo toast to expire.
public enum PendingRemoval: Sendable, Hashable {
    case event(localIdentifier: String, occurrenceDate: Date?, span: EventEditSpan)
    case reminder(localIdentifier: String)

    public func hides(_ event: CalendarEvent) -> Bool {
        hides(event.reference, kind: .event)
    }

    public func hides(_ reminder: ReminderItem) -> Bool {
        hides(reminder.reference, kind: .reminder)
    }

    public func hides(_ reference: CalendarItemReference, kind: CalendarItemKind) -> Bool {
        switch self {
        case .reminder(let localIdentifier):
            return kind == .reminder && reference.localIdentifier == localIdentifier
        case .event(let localIdentifier, let occurrenceDate, let span):
            guard kind == .event, reference.localIdentifier == localIdentifier else { return false }
            switch span {
            case .allEvents:
                return true
            case .futureEvents:
                guard let occurrenceDate, let candidateDate = reference.occurrenceDate else { return true }
                return candidateDate >= occurrenceDate
            case .thisEvent:
                return reference.occurrenceDate == occurrenceDate
            }
        }
    }
}
