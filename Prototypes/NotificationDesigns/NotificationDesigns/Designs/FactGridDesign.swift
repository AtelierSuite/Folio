import SwiftUI

struct FactGridDesign: View {
    let alert: SampleAlert

    private struct Fact: Identifiable {
        let label: String
        let value: String
        var id: String { label }
    }

    private var facts: [Fact] {
        var facts = [Fact(label: "Time", value: alert.rangeText)]
        if let timeSpan = alert.timeSpan {
            facts.append(Fact(label: "Duration", value: timeSpan.duration))
        }
        if let place = alert.place {
            facts.append(Fact(label: "Place", value: place))
        }
        if let meeting = alert.meeting {
            facts.append(Fact(label: "Meeting", value: meeting.name))
        }
        return facts
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 6) {
                CalendarSourceLabel(alert: alert)
                AlertTitle(alert: alert)
                    .multilineTextAlignment(.center)
                if let status = alert.status {
                    Text(status)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(alert.color)
                }
            }
            VStack(spacing: 8) {
                ForEach(Array(stride(from: 0, to: facts.count, by: 2)), id: \.self) { index in
                    HStack(spacing: 8) {
                        tile(for: facts[index])
                        if index + 1 < facts.count {
                            tile(for: facts[index + 1])
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
    }

    private func tile(for fact: Fact) -> some View {
        VStack(spacing: 2) {
            Text(fact.label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
            Text(fact.value)
                .font(.footnote.weight(.semibold))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.primary.opacity(0.07), in: .rect(cornerRadius: 12))
    }
}
