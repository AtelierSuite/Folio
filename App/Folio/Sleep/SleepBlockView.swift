import Planner
import SwiftUI

/// Sleep is shaded in one muted hue so it sits quietly behind events.
struct SleepBlockView: View {
    let isAsleep: Bool
    let showsIcon: Bool

    var body: some View {
        Rectangle()
            .fill(Color.indigo.opacity(isAsleep ? 0.09 : 0.04))
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(Color.indigo.opacity(isAsleep ? 0.35 : 0.15))
                    .frame(width: 3)
            }
            .overlay(alignment: .topLeading) {
                if showsIcon {
                    Image(systemName: "bed.double.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.indigo.opacity(0.6))
                        .padding(.leading, 7)
                        .padding(.top, 3)
                }
            }
            .clipped()
    }
}
