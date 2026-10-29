import SwiftUI

struct MonthSettingsSection: View {
    @AppStorage(MonthSettings.showsWeekNumbersKey) private var showsWeekNumbers = false

    var body: some View {
        Section(String(localized: "Settings.Header", table: "Month")) {
            Toggle(String(localized: "Settings.ShowsWeekNumbers", table: "Month"), isOn: $showsWeekNumbers)
                .accessibilityIdentifier("MonthWeekNumbersToggle")
        }
    }
}
