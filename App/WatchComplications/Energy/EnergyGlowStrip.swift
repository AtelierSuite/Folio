import Planner
import SwiftUI

/// Today's energy glow from waking to midnight, laid on its side: the app's orange peak glow rises
/// from the bottom edge and the indigo stripes mark the dip and wind-down. The rest of the day is dimmed.
struct EnergyGlowStrip: View {
    private static let futureOpacity = 0.45
    private static let lowReach = 0.65

    let curve: EnergyCurve
    let hour: Double

    var body: some View {
        Canvas { graphics, size in
            let startHour = curve.wakeHour ?? 0
            let hourWidth = size.width / max(24 - startHour, 1)
            let nowX = min(max((hour - startHour) * hourWidth, 0), size.width)

            var past = graphics
            past.clip(to: Path(CGRect(x: 0, y: 0, width: nowX, height: size.height)))
            drawGlow(in: past, size: size, startHour: startHour, hourWidth: hourWidth)

            var future = graphics
            future.clip(to: Path(CGRect(x: nowX, y: 0, width: size.width - nowX, height: size.height)))
            future.opacity = Self.futureOpacity
            drawGlow(in: future, size: size, startHour: startHour, hourWidth: hourWidth)

            graphics.fill(
                Path(CGRect(x: 0, y: size.height - 1, width: size.width, height: 1)),
                with: .color(.secondary.opacity(0.5))
            )
            if hour >= startHour {
                graphics.fill(
                    Path(roundedRect: CGRect(x: nowX - 1, y: 0, width: 2, height: size.height), cornerRadius: 1),
                    with: .color(.primary)
                )
            }
        }
    }

    /// Draws the app's vertical glow rotated so the day runs left to right and the glow reaches upwards.
    private func drawGlow(in graphics: GraphicsContext, size: CGSize, startHour: Double, hourWidth: CGFloat) {
        var day = graphics
        day.translateBy(x: 0, y: size.height)
        day.rotate(by: .degrees(-90))
        day.translateBy(x: 0, y: -startHour * hourWidth)
        let shading = EnergyGlowStyle.peakShading(curve, hourHeight: hourWidth, opacity: 1)
        day.drawSoftened { fraction in
            outline(reach: size.height * fraction, hourWidth: hourWidth, strength: curve.peakStrength(atHour:))
        } draw: { layer, area in
            layer.fill(area, with: shading)
        }
        day.drawSoftened { fraction in
            outline(
                reach: size.height * Self.lowReach * fraction, hourWidth: hourWidth,
                strength: curve.lowStrength(atHour:)
            )
        } draw: { layer, area in
            layer.drawEnergyStripes(in: area, color: EnergyGlowStyle.lowColor, opacity: 1)
        }
    }

    private func outline(reach: CGFloat, hourWidth: CGFloat, strength: (Double) -> Double) -> Path {
        EnergyGlowStyle.outline(edgeX: 0, reach: reach, direction: 1, hourHeight: hourWidth, strength: strength)
    }
}
