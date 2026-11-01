import Planner
import SwiftUI

struct HolidayRegionPicker: View {
    @Environment(\.locale) private var locale
    @Binding var storedRegion: String

    var body: some View {
        Picker(String(localized: "Settings.Region", table: "Holidays"), selection: $storedRegion) {
            Text(automaticLabel)
                .tag("")
            ForEach(DayHighlightSettings.sortedRegionCodes(in: locale), id: \.self) { regionCode in
                Text(DayHighlightSettings.regionName(for: regionCode, in: locale))
                    .tag(regionCode)
            }
        }
        .accessibilityIdentifier("HolidayRegionPicker")
    }

    private var automaticLabel: String {
        guard let regionCode = DayHighlightSettings.resolvedRegionCode(stored: "") else {
            return String(localized: "Settings.Automatic", table: "Holidays")
        }
        let regionName = DayHighlightSettings.regionName(for: regionCode, in: locale)
        return String(localized: "Settings.AutomaticRegion \(regionName)", table: "Holidays")
    }
}
