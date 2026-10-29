import Planner
import SwiftUI

struct EventRecurrenceSection: View {
    @Binding var recurrence: EventRecurrence?
    let startDate: Date

    private var frequency: Binding<EventRecurrence.Frequency?> {
        Binding(
            get: { recurrence?.frequency },
            set: { newValue in
                if let newValue {
                    recurrence = EventRecurrence(
                        frequency: newValue,
                        interval: recurrence?.interval ?? 1,
                        end: recurrence?.end ?? .never
                    )
                } else {
                    recurrence = nil
                }
            }
        )
    }

    var body: some View {
        Section {
            Picker(String(localized: "Field.Repeat", table: "EventEditor"), selection: frequency) {
                Text(String(localized: "Recurrence.Never", table: "EventEditor"))
                    .tag(EventRecurrence.Frequency?.none)
                ForEach(EventRecurrence.Frequency.allCases) { frequency in
                    Text(frequency.title)
                        .tag(Optional(frequency))
                }
            }
            if let current = recurrence {
                Stepper(
                    current.frequency.intervalTitle(current.interval),
                    value: Binding(get: { current.interval }, set: { recurrence?.interval = $0 }),
                    in: 1...99
                )
                EventRecurrenceEndRows(
                    end: Binding(get: { current.end }, set: { recurrence?.end = $0 }),
                    startDate: startDate
                )
            }
        }
    }
}
