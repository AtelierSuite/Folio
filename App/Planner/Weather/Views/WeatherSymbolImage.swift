import SwiftUI

/// A filled weather symbol with gradient palette colors, so white multicolor clouds never vanish on light backgrounds.
/// It fits in a square the size of the current font, so text beside it lines up whatever the condition.
public struct WeatherSymbolImage: View {
    private let symbolName: String

    public init(_ symbolName: String) {
        self.symbolName = symbolName
    }

    public var body: some View {
        let palette = WeatherSymbolPalette(symbolName: symbolName)
        Image(systemName: "square.fill")
            .hidden()
            .overlay {
                Image(systemName: symbolName)
                    .resizable()
                    .symbolVariant(.fill)
                    .scaledToFit()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(palette.primary, palette.secondary, palette.tertiary)
                    .symbolColorRenderingMode(.gradient)
            }
    }
}
