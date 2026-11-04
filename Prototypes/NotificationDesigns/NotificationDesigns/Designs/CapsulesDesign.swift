import SwiftUI

struct CapsulesDesign: View {
    let alert: SampleAlert

    var body: some View {
        VStack(spacing: 10) {
            CalendarSourceLabel(alert: alert)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(alert.color.opacity(0.16), in: .capsule)
            AlertTitle(alert: alert)
                .multilineTextAlignment(.center)
            CenteredFlowLayout {
                if let status = alert.status {
                    capsule(status, systemImage: "bell.fill", tint: alert.color)
                }
                capsule(alert.rangeText, systemImage: "clock")
                if let timeSpan = alert.timeSpan {
                    capsule(timeSpan.duration, systemImage: "hourglass")
                }
                if let place = alert.place {
                    capsule(place, systemImage: "mappin.and.ellipse")
                }
                if let meeting = alert.meeting {
                    capsule(meeting.name, systemImage: meeting.systemImage)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
    }

    private func capsule(_ text: String, systemImage: String, tint: Color = .primary) -> some View {
        Label(text, systemImage: systemImage)
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
            .font(.footnote.weight(.medium))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.primary.opacity(0.08), in: .capsule)
    }
}
