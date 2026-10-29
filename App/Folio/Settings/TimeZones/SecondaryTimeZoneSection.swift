import Planner
import SwiftUI

struct SecondaryTimeZoneSection: View {
    @Environment(SystemTimeObserver.self) private var systemTime
    @Environment(\.locale) private var locale
    @AppStorage(SecondaryTimeZoneSettings.isEnabledKey, store: AppGroup.userDefaults)
    private var isEnabled = false
    @AppStorage(SecondaryTimeZoneSettings.identifierKey, store: AppGroup.userDefaults)
    private var identifier = ""

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.ShowsSecondary", table: "TimeZones"), isOn: $isEnabled)
                .accessibilityIdentifier("SecondaryTimeZoneToggle")
            if isEnabled {
                NavigationLink {
                    SecondaryTimeZonePickerView(identifier: $identifier)
                } label: {
                    LabeledContent(
                        String(localized: "Settings.Zone", table: "TimeZones"),
                        value: selectedName
                    )
                }
                .accessibilityIdentifier("SecondaryTimeZoneLink")
            }
        } header: {
            Text(String(localized: "Settings.Header", table: "TimeZones"))
        } footer: {
            Text(String(localized: "Settings.Footer \(systemTimeZoneName)", table: "TimeZones"))
        }
    }

    private var selectedName: String {
        TimeZoneOption(identifier: identifier, locale: locale)?.displayName
            ?? String(localized: "Settings.ZoneNone", table: "TimeZones")
    }

    private var systemTimeZoneName: String {
        TimeZoneOption(identifier: systemTime.timeZone.identifier, locale: locale)?.displayName
            ?? systemTime.timeZone.identifier
    }
}
