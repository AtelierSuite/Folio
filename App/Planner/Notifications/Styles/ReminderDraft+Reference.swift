import Foundation

extension ReminderDraft {
    public func reference(localIdentifier: String) -> CalendarItemReference {
        CalendarItemReference(
            externalIdentifier: nil,
            localIdentifier: localIdentifier,
            calendarIdentifier: listIdentifier,
            title: title
        )
    }
}
