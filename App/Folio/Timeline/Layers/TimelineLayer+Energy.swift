import SwiftUI

extension TimelineLayer {
    static func energy(bleedsUnderEvents: Bool) -> [TimelineLayer] {
        let hourLabels = [
            TimelineLayer(id: "energyHourLabels", placement: .behindHourLabels) { context in
                EnergyHourLabelGlowView(context: context)
            },
            TimelineLayer(id: "energyHourGauge", placement: .behindHourLabels) { context in
                EnergyHourGaugeView(context: context)
            }
        ]
        guard bleedsUnderEvents else { return hourLabels }
        return hourLabels + [
            TimelineLayer(id: "energyBleed", placement: .belowEntries) { context in
                EnergyBleedView(context: context)
            }
        ]
    }
}
