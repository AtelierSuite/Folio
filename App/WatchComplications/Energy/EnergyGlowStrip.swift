import Planner
import SwiftUI

/// Today's energy glow, laid on its side: the app's orange peak glow rises from the bottom edge and
/// the indigo stripes mark the dip and wind-down. The rest of the day is dimmed. It spans from waking
/// to midnight unless given a window of hours.
struct EnergyGlowStrip: View {
    private static let futureOpacity = 0.45
    private static let peakReach = 0.85
    private static let lowReach = 0.6
    private static let blurRadius: CGFloat = 5

    let curve: EnergyCurve
    let hour: Double
    var window: ClosedRange<Double>?
    var showsBaseline = true

    var body: some View {
        Canvas { graphics, size in
            let startHour = window?.lowerBound ?? curve.wakeHour ?? 0
            let endHour = window?.upperBound ?? 24
            let hourWidth = size.width / max(endHour - startHour, 1)
            let nowX = min(max((hour - startHour) * hourWidth, 0), size.width)

            var past = graphics
            past.clip(to: Path(CGRect(x: 0, y: 0, width: nowX, height: size.height)))
            drawGlow(in: past, size: size, startHour: startHour, hourWidth: hourWidth)

            var future = graphics
            future.clip(to: Path(CGRect(x: nowX, y: 0, width: size.width - nowX, height: size.height)))
            future.opacity = Self.futureOpacity
            drawGlow(in: future, size: size, startHour: startHour, hourWidth: hourWidth)

            if showsBaseline {
                graphics.fill(
                    Path(CGRect(x: 0, y: size.height - 1, width: size.width, height: 1)),
                    with: .color(.secondary.opacity(0.5))
                )
            }
            if curve.level(atHour: hour) != nil {
                drawNowMarker(in: graphics, x: nowX, height: size.height)
            }
        }
    }

    /// A hairline that fades out upwards, rising from a dot on the baseline.
    private func drawNowMarker(in graphics: GraphicsContext, x nowX: CGFloat, height: CGFloat) {
        let dotSize: CGFloat = showsBaseline ? 5 : 0
        let lineBottom = height - dotSize / 2
        graphics.fill(
            Path(roundedRect: CGRect(x: nowX - 0.75, y: 0, width: 1.5, height: lineBottom), cornerRadius: 0.75),
            with: .linearGradient(
                Gradient(colors: [.primary.opacity(0), .primary.opacity(0.9)]),
                startPoint: CGPoint(x: nowX, y: height * 0.1),
                endPoint: CGPoint(x: nowX, y: lineBottom)
            )
        )
        if dotSize > 0 {
            graphics.fill(
                Path(ellipseIn: CGRect(x: nowX - dotSize / 2, y: height - dotSize, width: dotSize, height: dotSize)),
                with: .color(.primary)
            )
        }
    }

    /// Draws the app's vertical glow rotated so the day runs left to right and the glow reaches upwards.
    /// Each glow is masked by its blurred outline, fading upwards, so it softens without the banding
    /// that stacked translucent copies leave at full strength.
    private func drawGlow(in graphics: GraphicsContext, size: CGSize, startHour: Double, hourWidth: CGFloat) {
        var day = graphics
        day.translateBy(x: 0, y: size.height)
        day.rotate(by: .degrees(-90))
        day.translateBy(x: 0, y: -startHour * hourWidth)
        let dayArea = Path(CGRect(x: -size.height, y: 0, width: size.height * 3, height: 24 * hourWidth))
        let peak = SmoothedEnergyStrength(curve.peakStrength(atHour:))
        let low = SmoothedEnergyStrength(curve.lowStrength(atHour:))

        var peakLayer = day
        peakLayer.clipToLayer { mask in
            fillFadingMask(mask, reach: size.height * Self.peakReach, hourWidth: hourWidth) { Self.dome(peak($0)) }
        }
        peakLayer.fill(dayArea, with: peakShading(peak, hourWidth: hourWidth))

        var lowLayer = day
        lowLayer.clipToLayer { mask in
            fillFadingMask(mask, reach: size.height * Self.lowReach, hourWidth: hourWidth) { low($0) }
        }
        lowLayer.drawEnergyStripes(in: dayArea, color: EnergyGlowStyle.lowColor, opacity: 0.9)
    }

    private func fillFadingMask(
        _ mask: GraphicsContext, reach: CGFloat, hourWidth: CGFloat, strength: (Double) -> Double
    ) {
        var mask = mask
        mask.addFilter(.blur(radius: Self.blurRadius))
        let overhang = Self.blurRadius * 2
        let area = EnergyGlowStyle.outline(
            edgeX: -overhang, reach: reach + overhang, direction: 1, hourHeight: hourWidth, strength: strength
        )
        mask.fill(area, with: .linearGradient(
            Gradient(colors: [.white, .white.opacity(0.15)]),
            startPoint: .zero,
            endPoint: CGPoint(x: reach, y: 0)
        ))
    }

    private func peakShading(_ peak: SmoothedEnergyStrength, hourWidth: CGFloat) -> GraphicsContext.Shading {
        let stops = stride(from: 0.0, through: 24, by: 0.25).map { hour in
            Gradient.Stop(
                color: EnergyGlowStyle.peakColor.opacity(peak.intensity(hour)),
                location: hour / 24
            )
        }
        return .linearGradient(
            Gradient(stops: stops),
            startPoint: .zero,
            endPoint: CGPoint(x: 0, y: 24 * hourWidth)
        )
    }

    /// Eases the strength out so a peak's top rounds over instead of coming to a point.
    private static func dome(_ strength: Double) -> Double {
        1 - pow(1 - min(strength, 1), 2)
    }

}
