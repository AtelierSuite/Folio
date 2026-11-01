import Planner
import SwiftUI

struct DayHighlightEnvironment: ViewModifier {
    @Environment(WorkWeekPreferences.self) private var workWeek
    @Environment(SystemTimeObserver.self) private var systemTime
    @AppStorage(DayHighlightSettings.highlightsWeekendsKey, store: AppGroup.userDefaults)
    private var highlightsWeekends = false
    @AppStorage(DayHighlightSettings.highlightsHolidaysKey, store: AppGroup.userDefaults)
    private var highlightsHolidays = false
    @AppStorage(DayHighlightSettings.holidayRegionKey, store: AppGroup.userDefaults)
    private var storedRegion = ""
    @State private var holidays: [Holiday] = []

    func body(content: Content) -> some View {
        content
            .environment(\.dayHighlighter, highlighter)
            .task(id: holidayRequest) {
                guard let holidayRequest, let source = HolidaySource(regionCode: holidayRequest.regionCode) else {
                    holidays = []
                    return
                }
                holidays = await HolidayRepository().holidays(for: source)
            }
    }

    private var highlighter: DayHighlighter {
        let weekendWeekdays = highlightsWeekends ? Set(Calendar.weekdays).subtracting(workWeek.workdays) : []
        return DayHighlighter(weekendWeekdays: weekendWeekdays, holidays: highlightsHolidays ? holidays : [])
    }

    private var holidayRequest: HolidayRequest? {
        guard highlightsHolidays,
              let regionCode = DayHighlightSettings.resolvedRegionCode(stored: storedRegion) else { return nil }
        return HolidayRequest(regionCode: regionCode, systemTimeChangeCount: systemTime.changeCount)
    }
}

private struct HolidayRequest: Hashable {
    let regionCode: String
    let systemTimeChangeCount: Int
}

extension View {
    func providesDayHighlights() -> some View {
        modifier(DayHighlightEnvironment())
    }
}
