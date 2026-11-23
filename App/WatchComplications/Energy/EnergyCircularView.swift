import Planner
import SwiftUI
import WidgetKit

/// Today from waking to midnight as a ring in the app's glow colors, open at the top, with a dot at now
/// and the bolt filled to the current level in the middle.
struct EnergyCircularView: View {
    private static let ringWidth: CGFloat = 5
    private static let dotSize: CGFloat = 7
    private static let gapDegrees = 36.0

    let entry: EnergyComplicationEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            ring(.secondary.opacity(0.35))
            let peak = SmoothedEnergyStrength(entry.curve.peakStrength(atHour:))
            let low = SmoothedEnergyStrength(entry.curve.lowStrength(atHour:))
            ring(arcGradient(color: EnergyGlowStyle.peakColor) { peak.intensity($0) })
            ring(arcGradient(color: EnergyGlowStyle.lowColor) { low($0) })
            if entry.level != nil {
                nowDot
            }
            EnergyLevelIcon(filledSegments: entry.filledSegments, size: 20)
                .widgetAccentable()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "Energy.Title", table: "Complications"))
        .accessibilityValue(entry.levelName)
    }

    private var startHour: Double {
        entry.curve.wakeHour ?? 0
    }

    private static var arcFraction: Double {
        (360 - gapDegrees) / 360
    }

    /// The angle from the top for a fraction of the waking day along the arc.
    private static func angle(atFraction fraction: Double) -> Angle {
        .degrees(-90 + gapDegrees / 2 + fraction * (360 - gapDegrees))
    }

    private func ring(_ style: some ShapeStyle) -> some View {
        Circle()
            .inset(by: Self.ringWidth / 2 + 2)
            .trim(from: 0, to: Self.arcFraction)
            .stroke(style, style: StrokeStyle(lineWidth: Self.ringWidth, lineCap: .round))
            .rotationEffect(Self.angle(atFraction: 0))
    }

    /// Laid out from 3 o'clock, as the ring is drawn before it is turned to start beside the gap.
    private func arcGradient(color: Color, strength: (Double) -> Double) -> AngularGradient {
        let span = max(24 - startHour, 1)
        let stops = stride(from: 0.0, through: 1, by: 0.02).map { location in
            Gradient.Stop(color: color.opacity(strength(startHour + location * span)), location: location)
        }
        return AngularGradient(
            stops: stops, center: .center, startAngle: .zero, endAngle: .degrees(360 - Self.gapDegrees)
        )
    }

    private var nowDot: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2 - Self.ringWidth / 2 - 2
            let fraction = (entry.hour - startHour) / max(24 - startHour, 1)
            let angle = Self.angle(atFraction: min(max(fraction, 0), 1))
            Circle()
                .fill(.primary)
                .frame(width: Self.dotSize, height: Self.dotSize)
                .position(
                    x: geometry.size.width / 2 + radius * cos(angle.radians),
                    y: geometry.size.height / 2 + radius * sin(angle.radians)
                )
        }
    }
}
