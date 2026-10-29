import SwiftUI

struct TimelineSecondaryTimeZoneHeader: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 2)
            .accessibilityLabel(String(localized: "Column.AccessibilityLabel \(label)", table: "TimeZones"))
            .accessibilityIdentifier("SecondaryTimeZoneHeader")
    }
}
