import SwiftUI

/// A filled weather symbol with gradient palette colors, so white multicolor clouds never vanish on light backgrounds.
public struct WeatherSymbolImage: View {
    private let symbolName: String

    public init(_ symbolName: String) {
        self.symbolName = symbolName
    }

    public var body: some View {
        let palette = WeatherSymbolPalette(symbolName: symbolName)
        Image(systemName: symbolName)
            .symbolVariant(.fill)
            .symbolRenderingMode(.palette)
            .foregroundStyle(palette.primary, palette.secondary, palette.tertiary)
            .symbolColorRenderingMode(.gradient)
    }
}
