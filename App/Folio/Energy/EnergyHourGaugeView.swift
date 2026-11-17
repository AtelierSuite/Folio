import Planner
import SwiftUI

/// A bolt halfway down each waking hour of the hour column, filled to that hour's energy.
struct EnergyHourGaugeView: View {
    let context: TimelineLayerContext

    private var curve: EnergyCurve? {
        context.days.intervals.first.map {
            EnergyPreview.curve(forDayStarting: $0.start, calendar: context.days.calendar)
        }
    }

    var body: some View {
        if let curve {
            ZStack(alignment: .topLeading) {
                ForEach(0..<24, id: \.self) { hour in
                    if let filled = curve.gaugeSegments(forHourStarting: hour) {
                        EnergyBoltGauge(filledSegments: filled)
                            .position(x: 10, y: (CGFloat(hour) + 0.5) * context.hourHeight)
                    }
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
