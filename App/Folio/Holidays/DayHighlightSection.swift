import Planner
import SwiftUI

struct DayHighlightSection: View {
    @AppStorage(DayHighlightSettings.highlightsWeekendsKey, store: AppGroup.userDefaults)
    private var highlightsWeekends = false
    @AppStorage(DayHighlightSettings.highlightsHolidaysKey, store: AppGroup.userDefaults)
    private var highlightsHolidays = false
    @AppStorage(DayHighlightSettings.holidayRegionKey, store: AppGroup.userDefaults)
    private var storedRegion = ""

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.Weekends", table: "Holidays"), isOn: $highlightsWeekends)
                .accessibilityIdentifier("HighlightWeekendsToggle")
            Toggle(String(localized: "Settings.Holidays", table: "Holidays"), isOn: $highlightsHolidays)
                .accessibilityIdentifier("HighlightHolidaysToggle")
            if highlightsHolidays {
                HolidayRegionPicker(storedRegion: $storedRegion)
                if let regionCode = DayHighlightSettings.resolvedRegionCode(stored: storedRegion),
                   let source = HolidaySource(regionCode: regionCode) {
                    HolidayRefreshButton(source: source)
                }
            }
        } header: {
            Text(String(localized: "Settings.Header", table: "Holidays"))
        } footer: {
            Text(footer)
        }
    }

    private var footer: String {
        let sources = String(localized: "Settings.Footer", table: "Holidays")
        guard highlightsHolidays, DayHighlightSettings.resolvedRegionCode(stored: storedRegion) == nil else {
            return sources
        }
        return String(localized: "Settings.Unavailable", table: "Holidays") + "\n" + sources
    }
}
