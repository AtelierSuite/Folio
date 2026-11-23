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
                let lowShading = EnergyGlowStyle.lowShading(curve, hourHeight: context.hourHeight, boost: 1.6)
                graphics.drawTinted(with: lowShading, in: CGRect(origin: .zero, size: size)) { layer in
                    layer.drawSoftened { fraction in
                        EnergyGlowStyle.outline(
                            edgeX: size.width, reach: size.width * fraction, direction: -1,
                            hourHeight: context.hourHeight
                        ) { min(curve.lowStrength(atHour: $0) * 1.6, 1) }
                    } draw: { copy, area in
                        copy.drawEnergyStripes(in: area, color: .white, opacity: 1)
                    }
                }
            }
            .opacity(context.todayOnScreen)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
