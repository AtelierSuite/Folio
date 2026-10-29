import Foundation

extension CalendarStore {
    public func reminder(matching reference: CalendarItemReference, now: Date = .now) async -> ReminderItem? {
        let recentlyCompleted = DateInterval(start: now.addingTimeInterval(-86_400), end: now)
        let candidates = await source.reminders(completedIn: recentlyCompleted)
        guard let match = reference.bestMatch(in: candidates.map(\.reference)) else { return nil }
        return candidates.first { $0.reference == match }
    }
}
