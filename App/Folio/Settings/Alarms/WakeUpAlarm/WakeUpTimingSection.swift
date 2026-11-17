import Planner
import SwiftUI

struct WakeUpTimingSection: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms

    var body: some View {
        Section(String(localized: "Section.Timing", table: "WakeUpAlarms")) {
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
        }
    }
}
