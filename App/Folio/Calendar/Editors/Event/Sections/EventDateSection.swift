import Planner
import SwiftUI

struct EventDateSection: View {
    @Binding var draft: EventDraft
    var calendar: Calendar = .current

    private var components: DatePickerComponents {
        draft.isAllDay ? .date : [.date, .hourAndMinute]
    }

    private var isAllDay: Binding<Bool> {
        Binding(get: { draft.isAllDay }, set: { draft.setAllDay($0, calendar: calendar) })
    }

    private var startDate: Binding<Date> {
        Binding(get: { draft.startDate }, set: { draft.moveStart(to: $0) })
    }

    /// All-day events end at midnight after their last day, so the picker shows the last day instead.
    private var endDate: Binding<Date> {
        Binding(
            get: { draft.isAllDay ? lastAllDay : draft.endDate },
            set: { newValue in
                draft.endDate = draft.isAllDay
                    ? calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: newValue)) ?? newValue
                    : newValue
            }
        )
    }

    private var lastAllDay: Date {
        calendar.date(byAdding: .day, value: -1, to: draft.endDate).map { max($0, draft.startDate) } ?? draft.startDate
    }

    var body: some View {
        Section {
            Toggle(String(localized: "Field.AllDay", table: "EventEditor"), isOn: isAllDay)
            DatePicker(
                String(localized: "Field.Starts", table: "EventEditor"),
                selection: startDate,
                displayedComponents: components
            )
            DatePicker(
                String(localized: "Field.Ends", table: "EventEditor"),
                selection: endDate,
                in: draft.startDate...,
                displayedComponents: components
            )
            if let timeZone = draft.timeZone, timeZone.identifier != calendar.timeZone.identifier {
                EventTimeZoneRow(timeZone: timeZone) {
                    draft.timeZone = calendar.timeZone
                }
            }
        }
    }
}

private struct EventTimeZoneRow: View {
    let timeZone: TimeZone
    let useSystemTimeZone: () -> Void

    var body: some View {
        LabeledContent(String(localized: "Field.TimeZone", table: "EventEditor")) {
            Text(timeZone.localizedName(for: .generic, locale: .current) ?? timeZone.identifier)
        }
        Button(String(localized: "Field.TimeZone.UseSystem", table: "EventEditor"), action: useSystemTimeZone)
    }
}
