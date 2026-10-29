import Planner
import SwiftUI

struct WorkWeekDaysSection: View {
    @Environment(WorkWeekPreferences.self) private var workWeek
    private let calendar = Calendar.autoupdatingCurrent

    var body: some View {
        Section {
            ForEach(calendar.orderedWeekdays, id: \.self) { weekday in
                Toggle(calendar.standaloneWeekdaySymbols[weekday - 1], isOn: Binding(
                    get: { workWeek.isWorkday(weekday) },
                    set: { workWeek.setWorkday($0, for: weekday) }
                ))
                .disabled(workWeek.workdays == [weekday])
                .accessibilityIdentifier("WorkWeek.Day.\(weekday)")
            }
            if !workWeek.isUsingLocaleWorkdays {
                Button(String(localized: "WorkWeek.UseRegionDefault", table: "Week")) {
                    workWeek.useLocaleWorkdays()
                }
                .accessibilityIdentifier("WorkWeek.UseRegionDefault")
            }
        } header: {
            Text(String(localized: "WorkWeek.Section.Days", table: "Week"))
        } footer: {
            Text(String(localized: "WorkWeek.Section.Days.Footer", table: "Week"))
        }
    }
}
