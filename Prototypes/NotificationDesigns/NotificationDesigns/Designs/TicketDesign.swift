import SwiftUI

struct TicketDesign: View {
    let alert: SampleAlert

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 6) {
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
                AlertTitle(alert: alert)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            perforation
            if let timeSpan = alert.timeSpan {
                HStack(alignment: .top, spacing: 8) {
                    stub(label: "Start", value: timeSpan.start)
                    stub(label: "Duration", value: timeSpan.duration)
                    stub(label: "End", value: timeSpan.end)
                }
            } else {
                Text(alert.timeSummary)
                    .font(.subheadline.weight(.semibold))
            }
            AlertPlaceLabels(alert: alert)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
    }

    private var perforation: some View {
        Line()
            .stroke(.secondary, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .frame(height: 1)
    }

    private func stub(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.footnote.weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private nonisolated struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            }
        }
    }
}
