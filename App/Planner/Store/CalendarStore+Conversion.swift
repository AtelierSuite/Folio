import Foundation

extension CalendarStore {
    func removeCreatedReminder(identifier: String) async throws {
        try await source.deleteReminder(identifier: identifier)
        await handleExternalChange()
    }

    /// `reference` is the first occurrence, so a repeating event goes with all its occurrences.
    func removeCreatedEvent(at reference: CalendarItemReference, isRecurring: Bool) async throws {
        try await source.deleteEvent(reference, span: isRecurring ? .futureEvents : .thisEvent)
        await handleExternalChange()
    }
}
