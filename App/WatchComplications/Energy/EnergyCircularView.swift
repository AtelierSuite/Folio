import Planner
import SwiftUI
import WidgetKit

/// Today from waking to midnight as a ring in the app's glow colors, with a dot at now
/// and the bolt filled to the current level in the middle.
struct EnergyCircularView: View {
    private static let ringWidth: CGFloat = 5
    private static let dotSize: CGFloat = 7

    let entry: EnergyComplicationEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            ring(.secondary.opacity(0.35))
            ring(AngularGradient(stops: stops(color: EnergyGlowStyle.peakColor) { hour in
                min(entry.curve.peakStrength(atHour: hour) * 1.8, 1)
            }, center: .center, startAngle: .degrees(-90), endAngle: .degrees(270)))
            ring(AngularGradient(stops: stops(color: EnergyGlowStyle.lowColor) { hour in
                entry.curve.lowStrength(atHour: hour)
            }, center: .center, startAngle: .degrees(-90), endAngle: .degrees(270)))
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

    private func ring(_ style: some ShapeStyle) -> some View {
        Circle()
            .inset(by: Self.ringWidth / 2 + 2)
            .stroke(style, lineWidth: Self.ringWidth)
    }

    private func stops(color: Color, strength: (Double) -> Double) -> [Gradient.Stop] {
        let span = max(24 - startHour, 1)
        return stride(from: 0.0, through: 1, by: 0.02).map { location in
            Gradient.Stop(color: color.opacity(strength(startHour + location * span)), location: location)
        }
    }

    private var nowDot: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2 - Self.ringWidth / 2 - 2
            let fraction = (entry.hour - startHour) / max(24 - startHour, 1)
            let angle = Angle.degrees(fraction * 360 - 90)
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
