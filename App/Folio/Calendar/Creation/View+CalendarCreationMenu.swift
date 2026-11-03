import Planner
import SwiftUI

extension View {
    /// Lets a double tap on an empty part of the calendar open a menu there to add an event or reminder.
    func calendarCreationMenu(calendar: Calendar) -> some View {
        modifier(CalendarCreationMenuModifier(calendar: calendar))
    }
}

private struct CalendarCreationMenuModifier: ViewModifier {
    let calendar: Calendar
    @Environment(\.platformCapabilities) private var capabilities
    @State private var request: CalendarCreationRequest?
    @State private var composer: CalendarCreationComposer?

    func body(content: Content) -> some View {
        content
            .environment(\.calendarCreation, CalendarCreationAction { slot, point in
                request = CalendarCreationRequest(slot: slot, point: point)
            })
            .overlay {
                PlatformMenuPresenter(request: menuRequest)
            }
            .coordinateSpace(CalendarCreationAction.coordinateSpace)
            .sheet(item: $composer) { composer in
                switch composer {
                case .event(let draft): EventEditorView(newDraft: draft)
                case .reminder(let slot): ReminderEditorView(initialDate: slot.date, hasDueTime: slot.hasTime)
                case .alarm(let slot): StandaloneAlarmComposerView(initialDate: StandaloneAlarm.suggestedFireDate(
                    at: slot.date, hasTime: slot.hasTime, now: .now, calendar: calendar
                ))
                }
            }
    }

    private var menuRequest: PlatformMenuRequest? {
        request.map { request in
            let entries = menuEntries(for: request.slot)
            return PlatformMenuRequest(id: request.id, point: request.point) {
                PlatformMenu(sections: [entries])
            }
        }
    }

    private func menuEntries(for slot: CalendarCreationSlot) -> [PlatformMenu.Entry] {
        let composer = $composer
        var entries = [
            PlatformMenu.Entry(
                title: String(localized: "Add.Event", table: "Calendar"),
                systemImage: "calendar.badge.plus",
                identifier: "CreationMenu.Event"
            ) { [calendar] in composer.wrappedValue = .event(at: slot, calendar: calendar) },
            PlatformMenu.Entry(
                title: String(localized: "Add.Reminder", table: "Calendar"),
                systemImage: "checklist",
                identifier: "CreationMenu.Reminder"
            ) { composer.wrappedValue = .reminder(slot) }
        ]
        if capabilities.supports(.alarms) {
            entries.append(PlatformMenu.Entry(
                title: String(localized: "Add.Alarm", table: "StandaloneAlarms"),
                systemImage: "alarm",
                identifier: "CreationMenu.Alarm"
            ) { composer.wrappedValue = .alarm(slot) })
        }
        return entries
    }
}

private struct CalendarCreationRequest {
    let id = UUID()
    let slot: CalendarCreationSlot
    let point: CGPoint
}
