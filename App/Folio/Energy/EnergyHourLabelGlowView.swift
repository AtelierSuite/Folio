import Planner
import SwiftUI

/// The part of the glow behind the hour labels.
struct EnergyHourLabelGlowView: View {
    let context: TimelineLayerContext

    private var curve: EnergyCurve? {
        context.days.intervals.first.map {
            EnergyPreview.curve(forDayStarting: $0.start, calendar: context.days.calendar)
        }
    }

    var body: some View {
        if let curve {
            Canvas { graphics, size in
                graphics.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: EnergyGlowStyle.peakShading(curve, hourHeight: context.hourHeight)
                )
                graphics.drawSoftened { fraction in
                    EnergyGlowStyle.outline(
                        edgeX: size.width, reach: size.width * fraction, direction: -1,
                        hourHeight: context.hourHeight
                    ) { min(curve.lowStrength(atHour: $0) * 1.6, 1) }
                } draw: { layer, area in
                    layer.drawEnergyStripes(in: area, color: EnergyGlowStyle.lowColor)
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
