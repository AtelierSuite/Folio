import SwiftUI

/// Colors for each layer of a weather symbol, read from the shapes its name lists in layer order.
public struct WeatherSymbolPalette: Equatable, Sendable {
    public let colors: [Color]

    public init(symbolName: String) {
        let shapes = symbolName.split(separator: ".").map(String.init).filter { $0 != "fill" }
        let layers = Self.layerOrderExceptions[shapes.joined(separator: ".")]
            ?? shapes.compactMap(Self.color(forShape:))
        colors = layers.isEmpty ? [.gray] : layers
    }

    private static let layerOrderExceptions: [String: [Color]] = [
        "sun.haze": [.gray, .orange],
        "sun.dust": [.gray, .orange],
        "moon.haze": [.gray, .indigo],
        "cloud.bolt.rain": [.gray, .blue]
    ]

    public var primary: Color { colors[0] }
    public var secondary: Color { colors.count > 1 ? colors[1] : primary }
    public var tertiary: Color { colors.count > 2 ? colors[2] : secondary }

    private static func color(forShape shape: String) -> Color? {
        switch shape {
        case "sun", "sunrise", "sunset": .orange
        case "moon": .indigo
        case "stars", "bolt": .yellow
        case "cloud", "smoke", "fog", "haze", "dust", "tornado": .gray
        case "rain", "drizzle", "heavyrain": .blue
        case "snow", "sleet", "hail", "snowflake": .cyan
        case "wind", "hurricane": .teal
        case "thermometer": .red
        default: nil
        }
    }
}
