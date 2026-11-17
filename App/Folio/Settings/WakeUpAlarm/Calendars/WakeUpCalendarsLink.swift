import Planner
import SwiftUI

struct WakeUpCalendarsLink: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms
    @Environment(CalendarStore.self) private var store

    var body: some View {
        NavigationLink {
            WakeUpCalendarsView()
        } label: {
            LabeledContent(String(localized: "Calendars", table: "WakeUpAlarms"), value: summary)
        }
        .accessibilityIdentifier("WakeUpCalendarsLink")
    }

    private var summary: String {
        let calendars = store.eventCalendars
        let includedCount = calendars.filter { wakeUpAlarms.includesCalendar($0.id) }.count
        if includedCount == calendars.count {
            return String(localized: "Calendars.All", table: "WakeUpAlarms")
        }
        return String(format: String(localized: "Calendars.Count", table: "WakeUpAlarms"), includedCount)
    }
}
