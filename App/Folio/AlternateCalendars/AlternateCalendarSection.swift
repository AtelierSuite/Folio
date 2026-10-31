import Planner
import SwiftUI

struct AlternateCalendarSection: View {
    @Environment(\.locale) private var locale
    @AppStorage(AlternateCalendar.storageKey) private var storedCalendar = ""

    var body: some View {
        Section {
            Picker(String(localized: "Settings.Calendar", table: "AlternateCalendars"), selection: $storedCalendar) {
                Text(String(localized: "Settings.Off", table: "AlternateCalendars"))
                    .tag("")
                ForEach(AlternateCalendar.sortedByName(in: locale)) { alternateCalendar in
                    Text(alternateCalendar.displayName(in: locale))
                        .tag(alternateCalendar.rawValue)
                }
            }
            .accessibilityIdentifier("AlternateCalendarPicker")
        } header: {
            Text(String(localized: "Settings.Header", table: "AlternateCalendars"))
        } footer: {
            Text(String(localized: "Settings.Footer", table: "AlternateCalendars"))
        }
    }
}
