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
                }
            }
    }

    private var menuRequest: PlatformMenuRequest? {
        request.map { request in
            PlatformMenuRequest(id: request.id, point: request.point) { [calendar, composer = $composer] in
                PlatformMenu(sections: [[
                    PlatformMenu.Entry(
                        title: String(localized: "Add.Event", table: "Calendar"),
                        systemImage: "calendar.badge.plus",
                        identifier: "CreationMenu.Event"
                    ) { composer.wrappedValue = .event(at: request.slot, calendar: calendar) },
                    PlatformMenu.Entry(
                        title: String(localized: "Add.Reminder", table: "Calendar"),
                        systemImage: "checklist",
                        identifier: "CreationMenu.Reminder"
                    ) { composer.wrappedValue = .reminder(request.slot) }
                ]])
            }
        }
    }
}

private struct CalendarCreationRequest {
    let id = UUID()
    let slot: CalendarCreationSlot
    let point: CGPoint
}
