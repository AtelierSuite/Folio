import Planner
import SwiftUI

/// The part of the glow behind the hour labels, with an icon at each peak, dip and wind-down.
struct EnergyHourLabelGlowView: View {
    let context: TimelineLayerContext

    private var curve: EnergyCurve? {
        context.days.intervals.first.map {
            EnergyPreview.curve(forDayStarting: $0.start, calendar: context.days.calendar)
        }
    }

    var body: some View {
        if let curve {
            ZStack(alignment: .topLeading) {
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
                ForEach(Array(curve.markers.enumerated()), id: \.offset) { _, marker in
                    Image(systemName: EnergyGlowStyle.symbolName(for: marker.kind))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(EnergyGlowStyle.color(for: marker.kind))
                        .position(x: 10, y: iconY(for: marker))
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    /// Between hour labels, so the icon never sits on one.
    private func iconY(for marker: EnergyMarker) -> CGFloat {
        (marker.hour.rounded(.down) + 0.5) * context.hourHeight
    }
}
