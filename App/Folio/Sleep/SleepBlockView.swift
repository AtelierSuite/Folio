import Planner
import SwiftUI

/// Sleep is shaded in one muted hue so it sits quietly behind events.
struct SleepBlockView: View {
    let isAsleep: Bool

    var body: some View {
        Rectangle()
            .fill(Color.indigo.opacity(isAsleep ? 0.09 : 0.04))
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(Color.indigo.opacity(isAsleep ? 0.35 : 0.15))
                    .frame(width: 3)
            }
            .clipped()
    }
}
