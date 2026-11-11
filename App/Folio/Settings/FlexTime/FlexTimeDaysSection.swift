import Planner
import SwiftUI

struct FlexTimeDaysSection: View {
    @Environment(FlexTimeCenter.self) private var flexTime

    var body: some View {
        Section {
            ForEach(FlexTimeDayKind.allCases, id: \.self) { kind in
                Toggle(kind.title, isOn: Binding(
                    get: { flexTime.isEnabled(on: kind) },
                    set: { flexTime.setEnabled($0, on: kind) }
                ))
                .accessibilityIdentifier("FlexTimeToggle.\(kind.rawValue)")
            }
        } header: {
            Text(String(localized: "Settings.Days.Header", table: "FlexTime"))
        } footer: {
            Text(String(localized: "Settings.Days.Footer", table: "FlexTime"))
        }
    }
}

extension FlexTimeDayKind {
    var title: String {
        switch self {
        case .weekday: String(localized: "Settings.Weekdays", table: "FlexTime")
        case .weekend: String(localized: "Settings.Weekends", table: "FlexTime")
        case .publicHoliday: String(localized: "Settings.PublicHolidays", table: "FlexTime")
        }
    }
}
