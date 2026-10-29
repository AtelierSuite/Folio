import Planner
import SwiftUI

struct EventDetailSecondaryTimeZoneLabel: View {
    @Environment(\.timeZone) private var systemTimeZone
    @AppStorage(SecondaryTimeZoneSettings.isEnabledKey, store: AppGroup.userDefaults)
    private var isEnabled = false
    @AppStorage(SecondaryTimeZoneSettings.identifierKey, store: AppGroup.userDefaults)
    private var identifier = ""
    let event: CalendarEvent

    var body: some View {
        if let timeZone = SecondaryTimeZoneSettings.shownTimeZone(isEnabled: isEnabled, identifier: identifier),
           event.showsTime(in: timeZone, comparedTo: systemTimeZone) {
            let name = TimeZoneOption(identifier: timeZone.identifier)?.shortLabel ?? timeZone.identifier
            let times = (event.startDate..<event.endDate).formatted(
                Date.IntervalFormatStyle(timeZone: timeZone).hour().minute()
            )
            Label(String(localized: "Detail.SecondaryTime \(name) \(times)", table: "TimeZones"), systemImage: "globe")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("EventDetailSecondaryTime")
        }
    }
}
