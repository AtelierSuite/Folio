import Planner
import SwiftUI

struct EventRecurrenceEndRows: View {
    @Binding var end: EventRecurrence.End
    let startDate: Date

    private enum Kind: Hashable {
        case never
        case onDate
        case afterOccurrences
    }

    private var kind: Binding<Kind> {
        Binding(
            get: {
                switch end {
                case .never: .never
                case .onDate: .onDate
                case .afterOccurrences: .afterOccurrences
                }
            },
            set: { newValue in
                switch newValue {
                case .never: end = .never
                case .onDate:
                    end = .onDate(Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate)
                case .afterOccurrences: end = .afterOccurrences(10)
                }
            }
        )
    }

    var body: some View {
        Picker(String(localized: "Field.EndRepeat", table: "EventEditor"), selection: kind) {
            Text(String(localized: "Recurrence.End.Never", table: "EventEditor")).tag(Kind.never)
            Text(String(localized: "Recurrence.End.OnDate", table: "EventEditor")).tag(Kind.onDate)
            Text(String(localized: "Recurrence.End.After", table: "EventEditor")).tag(Kind.afterOccurrences)
        }
        switch end {
        case .never:
            EmptyView()
        case .onDate(let date):
            DatePicker(
                String(localized: "Recurrence.End.Date", table: "EventEditor"),
                selection: Binding(get: { date }, set: { end = .onDate($0) }),
                in: startDate...,
                displayedComponents: .date
            )
        case .afterOccurrences(let count):
            Stepper(
                String(localized: "Recurrence.End.Count \(count)", table: "EventEditor"),
                value: Binding(get: { count }, set: { end = .afterOccurrences($0) }),
                in: 2...999
            )
        }
    }
}
