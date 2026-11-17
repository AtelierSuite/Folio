import Planner
import SwiftUI

enum EnergyGlowStyle {
    static let peakColor = Color.orange
    static let lowColor = Color.indigo
    static let peakOpacity = 0.16
    static let stripeOpacity = 0.32
    static let stripeSpacing: CGFloat = 5
    static let stripeWidth: CGFloat = 1.2
    static let outlineStepHours = 1.0 / 12
    static let softeningLevels = 40

    /// The peak glow's opacity down the day, so it fades in and out with the curve.
    static func peakShading(_ curve: EnergyCurve, hourHeight: CGFloat) -> GraphicsContext.Shading {
        let stops = stride(from: 0.0, through: 24, by: 0.25).map { hour in
            Gradient.Stop(
                color: peakColor.opacity(peakOpacity * min(curve.peakStrength(atHour: hour) * 1.8, 1)),
                location: hour / 24
            )
        }
        return .linearGradient(
            Gradient(stops: stops),
            startPoint: .zero,
            endPoint: CGPoint(x: 0, y: 24 * hourHeight)
        )
    }

    /// A shape whose edge sits `reach × strength` away from `edgeX`, growing towards `direction`.
    static func outline(
        edgeX: CGFloat, reach: CGFloat, direction: CGFloat, hourHeight: CGFloat, strength: (Double) -> Double
    ) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: edgeX, y: 0))
        var hour = 0.0
        while hour <= 24 {
            path.addLine(to: CGPoint(x: edgeX + direction * reach * strength(hour), y: hour * hourHeight))
            hour += outlineStepHours
        }
        path.addLine(to: CGPoint(x: edgeX, y: 24 * hourHeight))
        path.closeSubpath()
        return path
    }
}
