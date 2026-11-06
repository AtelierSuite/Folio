import SwiftUI

enum AttentionKind {
    case invitation, conflict, overdueReminder
}

struct AttentionItem: Identifiable {
    var kind: AttentionKind
    var title: String
    var detail: String
    var tint: Color
    var id: String { "\(kind)-\(title)" }
}

enum AttentionCollector {
    static func items(in snapshot: LabSnapshot) -> [AttentionItem] {
        overdue(in: snapshot) + conflicts(in: snapshot) + invitations(in: snapshot)
    }

    static func conflictingPairs(in snapshot: LabSnapshot) -> [(LabEvent, LabEvent)] {
        let timed = snapshot.events
            .filter { !$0.isAllDay && $0.end > snapshot.now }
            .sorted { $0.start < $1.start }
        return timed.enumerated().flatMap { index, event in
            timed.dropFirst(index + 1)
                .filter { $0.start < event.end }
                .map { (event, $0) }
        }
    }

    private static func overdue(in snapshot: LabSnapshot) -> [AttentionItem] {
        snapshot.reminders.filter { $0.due < snapshot.now }.map { reminder in
            let days = snapshot.calendar.dateComponents(
                [.day],
                from: snapshot.calendar.startOfDay(for: reminder.due),
                to: snapshot.startOfToday
            ).day ?? 0
            let detail = days == 0 ? "Due today" : "\(days)d overdue"
            return AttentionItem(kind: .overdueReminder, title: reminder.title, detail: detail, tint: reminder.tint)
        }
    }

    private static func conflicts(in snapshot: LabSnapshot) -> [AttentionItem] {
        conflictingPairs(in: snapshot).map { first, second in
            AttentionItem(
                kind: .conflict,
                title: "\(first.title) / \(second.title)",
                detail: "Overlap at \(LabFormat.time(second.start))",
                tint: .orange
            )
        }
    }

    private static func invitations(in snapshot: LabSnapshot) -> [AttentionItem] {
        snapshot.events.filter { $0.awaitsMyResponse && $0.end > snapshot.now }.map { event in
            let day = snapshot.calendar.isDate(event.start, inSameDayAs: snapshot.now)
                ? "Today" : LabFormat.weekday(event.start)
            return AttentionItem(
                kind: .invitation,
                title: event.title,
                detail: "\(day) \(LabFormat.time(event.start))",
                tint: event.tint
            )
        }
    }
}
