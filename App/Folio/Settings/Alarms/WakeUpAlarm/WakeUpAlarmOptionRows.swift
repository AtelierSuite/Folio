import Planner
import SwiftUI

struct WakeUpAlarmOptionRows: View {
    static let leadOptions = [15, 30, 45, 60, 75, 90, 105, 120, 150, 180]

    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms

    var body: some View {
        Picker(String(localized: "LeadTime", table: "WakeUpAlarms"), selection: Binding(
            get: { wakeUpAlarms.leadMinutes },
            set: { newValue in Task { await wakeUpAlarms.setLeadMinutes(newValue) } }
        )) {
            ForEach(Self.leadOptions, id: \.self) { minutes in
                Text(leadText(minutes)).tag(minutes)
            }
        }
        .accessibilityIdentifier("WakeUpLeadTimePicker")
        MinutesOfDayPicker(
            title: String(localized: "Earliest", table: "WakeUpAlarms"),
            minutes: wakeUpAlarms.earliestMinutes,
            select: { minutes in Task { await wakeUpAlarms.setEarliestMinutes(minutes) } }
        )
        .accessibilityIdentifier("WakeUpEarliestPicker")
        MinutesOfDayPicker(
            title: String(localized: "LatestEvent", table: "WakeUpAlarms"),
            minutes: wakeUpAlarms.latestEventMinutes,
            select: { minutes in Task { await wakeUpAlarms.setLatestEventMinutes(minutes) } }
        )
        .accessibilityIdentifier("WakeUpLatestEventPicker")
        WakeUpHolidayToggle()
        WakeUpNextAlarmRow(alarm: wakeUpAlarms.upcomingAlarms.first)
    }

    private func leadText(_ minutes: Int) -> String {
        let duration = Duration.seconds(minutes * 60)
            .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
        return String(format: String(localized: "LeadTime.Value", table: "WakeUpAlarms"), duration)
    }
}
