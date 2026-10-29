import SwiftUI

struct TimelineSettingsSection: View {
    @AppStorage(TimelineSettings.compressesTextKey) private var compressesText = false

    var body: some View {
        Section {
            Toggle(String(localized: "Settings.CompressesText", table: "TimelineZoom"), isOn: $compressesText)
                .accessibilityIdentifier("TimelineCompressTextToggle")
        } header: {
            Text(String(localized: "Settings.Header", table: "TimelineZoom"))
        } footer: {
            Text(String(localized: "Settings.CompressesText.Footer", table: "TimelineZoom"))
        }
    }
}
