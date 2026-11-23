import Planner
import SwiftUI

/// The part of the glow behind the hour labels. It shows today, and fades as today scrolls away.
struct EnergyHourLabelGlowView: View {
    let context: TimelineLayerContext

    var body: some View {
        if context.todayOnScreen > 0 {
            let curve = EnergyPreview.todaysCurve(calendar: context.days.calendar)
            Canvas { graphics, size in
                graphics.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: EnergyGlowStyle.peakShading(curve, hourHeight: context.hourHeight)
                )
                let lowMask = EnergyGlowStyle.lowMask(curve, hourHeight: context.hourHeight, boost: 1.6)
                graphics.drawMasked(by: lowMask, in: CGRect(origin: .zero, size: size)) { masked in
                    masked.drawSoftened { fraction in
                        EnergyGlowStyle.outline(
                            edgeX: size.width, reach: size.width * fraction, direction: -1,
                            hourHeight: context.hourHeight
                        ) { min(curve.lowStrength(atHour: $0) * 1.6, 1) }
                    } draw: { layer, area in
                        layer.drawEnergyStripes(in: area, color: EnergyGlowStyle.lowColor)
                    }
                }
            }
            .opacity(context.todayOnScreen)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
