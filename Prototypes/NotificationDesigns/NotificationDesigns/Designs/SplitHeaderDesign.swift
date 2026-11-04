import SwiftUI

struct SplitHeaderDesign: View {
    let alert: SampleAlert

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                CalendarSourceLabel(alert: alert)
                Spacer(minLength: 0)
                if let status = alert.status {
                    Text(status)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(alert.color)
                        .fixedSize()
                }
            }
            Divider()
            VStack(spacing: 6) {
                AlertTitle(alert: alert)
                Text(alert.timeSummary)
                    .font(.subheadline)
            }
            .multilineTextAlignment(.center)
            if alert.place != nil || alert.meeting != nil {
                HStack(alignment: .top, spacing: 12) {
                    if let place = alert.place {
                        AlertDetailLabel(text: place, systemImage: "mappin.and.ellipse")
                    }
                    Spacer(minLength: 0)
                    if let meeting = alert.meeting {
                        AlertDetailLabel(text: meeting.name, systemImage: meeting.systemImage)
                            .fixedSize()
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }
}
