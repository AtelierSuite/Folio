import Planner
import SwiftUI

/// A bolt halfway down each of today's peak hours, filled to that hour's energy, and a hollow bolt
/// where each dip starts. It fades as today scrolls away.
struct EnergyHourGaugeView: View {
    let context: TimelineLayerContext

    var body: some View {
        if context.todayOnScreen > 0 {
            let curve = EnergyPreview.todaysCurve(calendar: context.days.calendar)
            ZStack(alignment: .topLeading) {
                ForEach(curve.peakGaugeHours, id: \.self) { hour in
                    if let filled = curve.gaugeSegments(forHourStarting: hour) {
                        bolt(filledSegments: filled, atHour: hour)
                    }
                }
                ForEach(curve.dipStartGaugeHours, id: \.self) { hour in
                    bolt(filledSegments: 0, atHour: hour)
                }
            }
            .opacity(context.todayOnScreen)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    private func bolt(filledSegments: Int, atHour hour: Int) -> some View {
        EnergyBoltGauge(filledSegments: filledSegments)
            .position(x: 10, y: (CGFloat(hour) + 0.5) * context.hourHeight)
    }
}
