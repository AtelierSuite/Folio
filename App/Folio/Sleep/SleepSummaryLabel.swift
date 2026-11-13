import SwiftUI

struct SleepSummaryLabel: View {
    let asleepDuration: TimeInterval

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "bed.double.fill")
            if asleepDuration >= 60 {
                Text(formattedDuration)
                    .monospacedDigit()
                    .lineLimit(1)
            }
        }
        .font(.caption2.weight(.medium))
        .foregroundStyle(Color.indigo.opacity(0.7))
        .padding(.leading, 7)
        .padding(.trailing, 2)
        .padding(.top, 3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .clipped()
    }

    private var formattedDuration: String {
        Duration.seconds(asleepDuration)
            .formatted(.units(allowed: [.hours, .minutes], width: .narrow))
    }
}
