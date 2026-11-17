import Planner
import SwiftUI

struct WakeUpHolidayToggle: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms
    @AppStorage(DayHighlightSettings.highlightsHolidaysKey, store: AppGroup.userDefaults)
    private var highlightsHolidays = false
    @AppStorage(DayHighlightSettings.holidayRegionKey, store: AppGroup.userDefaults)
    private var storedRegion = ""

    var body: some View {
        Group {
            if highlightsHolidays, DayHighlightSettings.resolvedRegionCode(stored: storedRegion) != nil {
                Toggle(String(localized: "SkipHolidays", table: "WakeUpAlarms"), isOn: Binding(
                    get: { wakeUpAlarms.skipsHolidays },
                    set: { newValue in Task { await wakeUpAlarms.setSkipsHolidays(newValue) } }
                ))
                .accessibilityIdentifier("WakeUpSkipHolidaysToggle")
            }
        }
        .task(id: "\(highlightsHolidays)|\(storedRegion)") {
            guard wakeUpAlarms.skipsHolidays else { return }
            await wakeUpAlarms.replan()
        }
    }
}
