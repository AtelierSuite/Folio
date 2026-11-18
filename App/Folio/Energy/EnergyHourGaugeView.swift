import Planner
import SwiftUI

/// A bolt halfway down each peak hour, filled to that hour's energy, and a hollow bolt where each dip starts.
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
                ForEach(curve.peakGaugeHours, id: \.self) { hour in
                    if let filled = curve.gaugeSegments(forHourStarting: hour) {
                        bolt(filledSegments: filled, atHour: hour)
                    }
                }
                ForEach(curve.dipStartGaugeHours, id: \.self) { hour in
                    bolt(filledSegments: 0, atHour: hour)
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    private func bolt(filledSegments: Int, atHour hour: Int) -> some View {
        EnergyBoltGauge(filledSegments: filledSegments)
            .position(x: 10, y: (CGFloat(hour) + 0.5) * context.hourHeight)
    }
}
