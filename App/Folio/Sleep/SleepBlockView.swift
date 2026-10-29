import Planner
import SwiftUI

/// Stages are shaded in one muted hue so sleep sits quietly behind events.
struct SleepBlockView: View {
    let stage: SleepStage
    let showsIcon: Bool

    var body: some View {
        Rectangle()
            .fill(Color.indigo.opacity(stage.fillOpacity))
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(Color.indigo.opacity(stage.edgeOpacity))
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

extension SleepStage {
    var fillOpacity: Double {
        switch self {
        case .inBed: 0.04
        case .awake: 0.02
        case .asleep, .core: 0.09
        case .rem: 0.12
        case .deep: 0.17
        }
    }

    var edgeOpacity: Double {
        switch self {
        case .inBed, .awake: 0.15
        case .asleep, .core: 0.35
        case .rem: 0.45
        case .deep: 0.6
        }
    }
}
