import Planner
import SwiftUI

/// The part of the glow that runs under events, from the leading edge of each day column.
/// Its width follows the curve, so it reaches furthest at the peaks.
struct EnergyBleedView: View {
    let context: TimelineLayerContext

    var body: some View {
        Canvas { graphics, size in
            let columnWidth = size.width / CGFloat(max(context.days.count, 1))
            let reach = min(96, columnWidth * 0.5)
            for (index, interval) in context.days.intervals.enumerated() {
                let curve = EnergyPreview.curve(forDayStarting: interval.start, calendar: context.days.calendar)
                let originX = CGFloat(index) * columnWidth
                let shading = EnergyGlowStyle.peakShading(curve, hourHeight: context.hourHeight)
                graphics.drawSoftened { fraction in
                    outline(originX: originX, reach: reach * fraction, strength: curve.peakStrength(atHour:))
                } draw: { layer, area in
                    layer.fill(area, with: shading)
                }
                graphics.drawSoftened { fraction in
                    outline(originX: originX, reach: reach * 0.65 * fraction, strength: curve.lowStrength(atHour:))
                } draw: { layer, area in
                    layer.drawEnergyStripes(in: area, color: EnergyGlowStyle.lowColor)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func outline(originX: CGFloat, reach: CGFloat, strength: (Double) -> Double) -> Path {
        EnergyGlowStyle.outline(
            edgeX: originX, reach: reach, direction: 1, hourHeight: context.hourHeight, strength: strength
        )
    }
}
