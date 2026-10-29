import Foundation

/// Finds the reminders App Intents refer to among the open ones and those completed in the last month.
public struct ReminderLookup: Sendable {
    static let completedLookback: TimeInterval = 30 * 86_400
    static let suggestedLimit = 20

    private let source: any CalendarDataSource
    private let visibilityStorage: CalendarVisibilityStorage

    public init(
        source: any CalendarDataSource = EventKitDataSource.shared,
        visibilityStorage: CalendarVisibilityStorage = CalendarVisibilityStorage()
    ) {
        self.source = source
        self.visibilityStorage = visibilityStorage
    }

    public func reminders(withIdentifiers identifiers: [ReminderEntity.ID], now: Date = .now) async -> [ReminderItem] {
        let candidates = await allReminders(now: now)
        return identifiers.compactMap { identifier in
            if let exact = candidates.first(where: { $0.reference.storageKey == identifier }) {
                return exact
            }
            guard let reference = CalendarItemReference(storageKey: identifier),
                  let match = reference.bestMatch(in: candidates.map(\.reference)) else { return nil }
            return candidates.first { $0.reference == match }
        }
    }

    /// Open reminders rank first, soonest due first.
    public func reminders(matching text: String, now: Date = .now) async -> [ReminderItem] {
        let words = IntentTextMatching.words(in: text)
        guard !words.isEmpty else { return await suggestedReminders(now: now) }
        let scored = await visibleReminders(now: now).compactMap { reminder in
            let score = IntentTextMatching.score(of: words, in: [reminder.title, reminder.notes])
            return score > 0 ? (reminder, score) : nil
        }
        guard let bestScore = scored.map(\.1).max() else { return [] }
        return scored.filter { $0.1 == bestScore }.map(\.0)
    }

    public func suggestedReminders(now: Date = .now) async -> [ReminderItem] {
        Array(await visibleReminders(now: now).filter { !$0.isCompleted }.prefix(Self.suggestedLimit))
    }

    public func visibleReminders(now: Date = .now) async -> [ReminderItem] {
        let hidden = visibilityStorage.hiddenCalendarIdentifiers
        return await allReminders(now: now)
            .filter { !hidden.contains($0.listIdentifier) }
            .sorted(by: Self.isOrderedBefore)
    }

    private func allReminders(now: Date) async -> [ReminderItem] {
        let recent = DateInterval(start: now.addingTimeInterval(-Self.completedLookback), end: now)
        return await source.reminders(completedIn: recent)
    }

    private static func isOrderedBefore(_ first: ReminderItem, _ second: ReminderItem) -> Bool {
        if first.isCompleted != second.isCompleted {
            return !first.isCompleted
        }
        return (first.dueDate ?? .distantFuture, first.title) < (second.dueDate ?? .distantFuture, second.title)
    }
}
