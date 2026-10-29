import SwiftUI

public struct PlannerColor: Sendable, Hashable, Codable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public static let gray = PlannerColor(red: 0.56, green: 0.56, blue: 0.58)

    public var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
