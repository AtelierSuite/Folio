import Planner
import SwiftUI

/// The quick action sections as a UIKit or AppKit menu, for menus opened at a tap point.
@MainActor
struct EventPlatformMenu {
    let event: CalendarEvent
    let actions: EventActions

    struct Entry {
        let title: String
        let systemImage: String
        let isDestructive: Bool
        let identifier: String
        let children: [Entry]
        let action: @MainActor () -> Void
    }

    var sections: [[Entry]] {
        actions.sections(for: event).map { $0.map(entry(for:)) }
    }

    private func entry(for item: EventMenuItem) -> Entry {
        let children: [Entry] = if case .moveToCalendar(let calendars) = item {
            calendars.map { calendar in
                Entry(
                    title: calendar.title, systemImage: "circle.fill", isDestructive: false,
                    identifier: "EventMenu.MoveTo.\(calendar.id)", children: []
                ) { [actions, event] in actions.move(event, to: calendar) }
            }
        } else {
            []
        }
        return Entry(
            title: item.title, systemImage: item.systemImage, isDestructive: item.isDestructive,
            identifier: item.accessibilityIdentifier, children: children
        ) { [actions, event] in actions.perform(item, on: event) }
    }
}
