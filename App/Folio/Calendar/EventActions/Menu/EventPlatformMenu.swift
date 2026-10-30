import Planner
import SwiftUI

/// The quick action sections as a UIKit or AppKit menu, for menus opened at a tap point.
@MainActor
struct EventPlatformMenu {
    let event: CalendarEvent
    let actions: EventActions

    var menu: PlatformMenu {
        PlatformMenu(sections: actions.sections(for: event).map { $0.map(entry(for:)) })
    }

    private func entry(for item: EventMenuItem) -> PlatformMenu.Entry {
        let children: [PlatformMenu.Entry] = if case .moveToCalendar(let calendars) = item {
            calendars.map { calendar in
                PlatformMenu.Entry(
                    title: calendar.title, systemImage: "circle.fill", identifier: "EventMenu.MoveTo.\(calendar.id)"
                ) { [actions, event] in actions.move(event, to: calendar) }
            }
        } else {
            []
        }
        return PlatformMenu.Entry(
            title: item.title, systemImage: item.systemImage, isDestructive: item.isDestructive,
            identifier: item.accessibilityIdentifier, children: children
        ) { [actions, event] in actions.perform(item, on: event) }
    }
}
