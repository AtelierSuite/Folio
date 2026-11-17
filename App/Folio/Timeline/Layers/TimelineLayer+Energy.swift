import SwiftUI

extension TimelineLayer {
    static var energy: [TimelineLayer] {
        [
            TimelineLayer(id: "energyHourGauge", placement: .behindHourLabels) { context in
                EnergyHourGaugeView(context: context)
            }
        ]
    }
}
