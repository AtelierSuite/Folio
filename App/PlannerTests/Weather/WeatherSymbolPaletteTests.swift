import SwiftUI
import Testing
@testable import Planner

struct WeatherSymbolPaletteTests {
    @Test func colorsEachShapeInLayerOrder() {
        let palette = WeatherSymbolPalette(symbolName: "cloud.sun.rain")
        #expect(palette.colors == [.gray, .orange, .blue])
    }

    @Test func ignoresTheFillSuffixAndModifiers() {
        #expect(WeatherSymbolPalette(symbolName: "sun.max.fill").colors == [.orange])
        #expect(WeatherSymbolPalette(symbolName: "cloud.fill").colors == [.gray])
    }

    @Test func usesExceptionsWhereLayersDoNotFollowTheName() {
        #expect(WeatherSymbolPalette(symbolName: "sun.haze").colors == [.gray, .orange])
        #expect(WeatherSymbolPalette(symbolName: "cloud.bolt.rain.fill").colors == [.gray, .blue])
    }

    @Test func repeatsTheLastColorForMissingLayers() {
        let palette = WeatherSymbolPalette(symbolName: "cloud.rain")
        #expect(palette.tertiary == .blue)
        #expect(WeatherSymbolPalette(symbolName: "unknown").primary == .gray)
    }
}
