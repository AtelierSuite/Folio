import Planner
import SwiftUI

struct FlexTimeEventPreviewList: View {
    let events: [CalendarEvent]
    let delay: TimeInterval
    @Binding var excludedCalendars: Set<String>

    var body: some View {
        VStack(spacing: 12) {
            ForEach(calendarIdentifiers, id: \.self) { calendarIdentifier in
                FlexTimeCalendarGroup(
                    calendarIdentifier: calendarIdentifier,
                    events: events.filter { $0.calendarIdentifier == calendarIdentifier },
                    delay: delay,
                    isIncluded: isIncluded(calendarIdentifier)
                )
            }
        }
    }

    private var calendarIdentifiers: [String] {
        var seen: Set<String> = []
        return events.map(\.calendarIdentifier).filter { seen.insert($0).inserted }
    }

    private func isIncluded(_ calendarIdentifier: String) -> Binding<Bool> {
        Binding {
            !excludedCalendars.contains(calendarIdentifier)
        } set: { isIncluded in
            if isIncluded {
                excludedCalendars.remove(calendarIdentifier)
            } else {
                excludedCalendars.insert(calendarIdentifier)
            }
        }
    }
}
