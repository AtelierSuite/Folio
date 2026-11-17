import SwiftUI

extension TimelineLayer {
    static var energy: [TimelineLayer] {
        [
            TimelineLayer(id: "energyHourLabels", placement: .behindHourLabels) { context in
                EnergyHourLabelGlowView(context: context)
            },
            TimelineLayer(id: "energyHourGauge", placement: .behindHourLabels) { context in
                EnergyHourGaugeView(context: context)
            },
            TimelineLayer(id: "energyBleed", placement: .belowEntries) { context in
                EnergyBleedView(context: context)
            }
        ]
    }
}
