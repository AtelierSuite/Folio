import Planner
import SwiftUI

/// The Apple Weather mark and legal link that must accompany weather wherever it appears.
struct WeatherAttributionView: View {
    @Environment(\.colorScheme) private var colorScheme
    let attribution: WeatherAttribution
    var alignment: Alignment = .center

    var body: some View {
        HStack(spacing: 8) {
            mark
            Link(String(localized: "Attribution.Legal", table: "Weather"), destination: attribution.legalPageURL)
                .accessibilityIdentifier("WeatherAttributionLink")
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: alignment)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var mark: some View {
        let url = colorScheme == .dark ? attribution.markDarkURL : attribution.markLightURL
        if let url {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                fallbackMark
            }
            .frame(height: 11)
            .accessibilityLabel(attribution.serviceName)
        } else {
            fallbackMark
        }
    }

    private var fallbackMark: some View {
        Label(String(localized: "Attribution.Weather", table: "Weather"), systemImage: "apple.logo")
            .labelStyle(.titleAndIcon)
            .accessibilityLabel(attribution.serviceName)
    }
}

struct WeatherAttributionFooter: View {
    let snapshot: WeatherSnapshot

    var body: some View {
        if snapshot.hasWeather {
            WeatherAttributionView(attribution: snapshot.attribution ?? .placeholder)
        }
    }
}
