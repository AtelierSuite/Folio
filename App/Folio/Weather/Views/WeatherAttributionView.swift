import Planner
import SwiftUI

/// The Apple Weather mark and legal link that must accompany weather wherever it appears.
struct WeatherAttributionView: View {
    let attribution: WeatherAttribution
    var alignment: Alignment = .center

    var body: some View {
        HStack(spacing: 8) {
            // WeatherKit's image mark is localised (天気 in Japanese), so the text mark keeps "Apple Weather" everywhere.
            Label {
                Text(verbatim: "Weather")
            } icon: {
                Image(systemName: "apple.logo")
            }
            .labelStyle(.titleAndIcon)
            .accessibilityLabel(attribution.serviceName)
            Link(String(localized: "Attribution.Legal", table: "Weather"), destination: attribution.legalPageURL)
                .accessibilityIdentifier("WeatherAttributionLink")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: alignment)
        .padding(.vertical, 4)
    }
}
