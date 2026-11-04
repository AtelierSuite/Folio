import SwiftUI

struct ColorWashDesign: View {
    let alert: SampleAlert

    var body: some View {
        VStack(spacing: 8) {
            CalendarSourceLabel(alert: alert)
            AlertTitle(alert: alert)
            Text(alert.rangeText)
                .font(.subheadline.weight(.semibold))
            if let timeSpan = alert.timeSpan {
                Text(timeSpan.duration)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let status = alert.status {
                Text(status)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(alert.color, in: .capsule)
            }
            AlertPlaceLabels(alert: alert)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(20)
        .background {
            LinearGradient(
                colors: [alert.color.opacity(0.32), alert.color.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
