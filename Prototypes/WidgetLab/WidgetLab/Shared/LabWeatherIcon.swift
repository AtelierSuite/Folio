import SwiftUI

/// Multicolor clouds are white, which vanishes on a light widget.
struct LabWeatherIcon: View {
    let symbol: String

    private var accent: Color {
        symbol.contains("rain") ? .blue : .orange
    }

    private var mainColor: Color {
        symbol.hasPrefix("cloud") ? .gray : .orange
    }

    var body: some View {
        Image(systemName: symbol)
            .symbolRenderingMode(.palette)
            .foregroundStyle(mainColor, accent)
    }
}
