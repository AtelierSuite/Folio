import Planner
import SwiftUI

/// The part of the glow that runs under events, from the leading edge of today's column.
/// Its width follows the curve, so it reaches furthest at the peaks, and it fades as today's
/// column scrolls out of view.
struct EnergyBleedView: View {
    let context: TimelineLayerContext

    var body: some View {
        let now = Date.now
        if let today = context.days.intervals.firstIndex(where: { $0.contains(now) }) {
            let curve = EnergyPreview.curve(
                forDayStarting: context.days.intervals[today].start, calendar: context.days.calendar
            )
            GeometryReader { proxy in
                let columnWidth = proxy.size.width / CGFloat(max(context.days.count, 1))
                EnergyDayBleedView(curve: curve, hourHeight: context.hourHeight)
                    .frame(width: columnWidth, height: proxy.size.height)
                    .visualEffect { content, proxy in
                        content.opacity(Self.onScreenFraction(of: proxy))
                    }
                    .offset(x: CGFloat(today) * columnWidth)
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    /// How much of the view is inside the horizontal scroll view's visible bounds, from 0 to 1.
    private nonisolated static func onScreenFraction(of proxy: GeometryProxy) -> Double {
        guard let viewport = proxy.bounds(of: .scrollView(axis: .horizontal)), proxy.size.width > 0 else {
            return 1
        }
        let visible = min(proxy.size.width, viewport.maxX) - max(0, viewport.minX)
        return Double(min(max(visible / proxy.size.width, 0), 1))
    }
}

/// The glow for one day column, drawn from its leading edge.
private struct EnergyDayBleedView: View {
    let curve: EnergyCurve
    let hourHeight: CGFloat

    var body: some View {
        Canvas { graphics, size in
            let reach = min(48, size.width * 0.3)
            let shading = EnergyGlowStyle.peakShading(curve, hourHeight: hourHeight)
            graphics.drawSoftened { fraction in
                outline(reach: reach * fraction, strength: curve.peakStrength(atHour:))
            } draw: { layer, area in
                layer.fill(area, with: shading)
            }
            graphics.drawSoftened { fraction in
                outline(reach: reach * 0.65 * fraction, strength: curve.lowStrength(atHour:))
            } draw: { layer, area in
                layer.drawEnergyStripes(in: area, color: EnergyGlowStyle.lowColor)
            }
        }
    }

    private func outline(reach: CGFloat, strength: (Double) -> Double) -> Path {
        EnergyGlowStyle.outline(edgeX: 0, reach: reach, direction: 1, hourHeight: hourHeight, strength: strength)
    }
}
