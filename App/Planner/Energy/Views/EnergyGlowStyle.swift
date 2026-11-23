import SwiftUI

public enum EnergyGlowStyle {
    public static let peakColor = Color.orange
    public static let lowColor = Color.indigo
    public static let peakOpacity = 0.16
    public static let stripeOpacity = 0.32
    public static let stripeSpacing: CGFloat = 5
    public static let stripeWidth: CGFloat = 1.2
    public static let outlineStepHours = 1.0 / 12
    public static let softeningLevels = 40

    /// The peak glow's opacity down the day, so it fades in and out with the curve.
    public static func peakShading(
        _ curve: EnergyCurve, hourHeight: CGFloat, opacity: Double = peakOpacity
    ) -> GraphicsContext.Shading {
        let stops = stride(from: 0.0, through: 24, by: 0.25).map { hour in
            Gradient.Stop(
                color: peakColor.opacity(opacity * min(curve.peakStrength(atHour: hour) * 1.8, 1)),
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
    public static func outline(
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
