import EventKit

extension EventKitDataSource {
    public func eventKitEvent(for reference: CalendarItemReference) -> EKEvent? {
        try? event(for: reference)
    }
}
