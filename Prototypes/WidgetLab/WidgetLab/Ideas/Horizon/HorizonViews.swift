import SwiftUI

private extension HorizonItem {
    var awayText: String {
        switch daysAway {
        case ..<14: "\(daysAway)d"
        case ..<60: "\(daysAway / 7)w"
        default: "\(daysAway / 30)mo"
        }
    }
}

private func longWeekendText(in snapshot: LabSnapshot) -> String? {
    guard let weekend = HorizonScale.nextLongWeekend(in: snapshot) else { return nil }
    let format = Date.FormatStyle.dateTime.month(.abbreviated).day()
    return "Next long weekend: \(weekend.start.formatted(format))–\(weekend.end.formatted(format))"
}

private struct HorizonAxis: View {
    let items: [HorizonItem]

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let lineY = proxy.size.height / 2
            ZStack(alignment: .topLeading) {
                Capsule()
                    .fill(.quaternary)
                    .frame(width: width, height: 3)
                    .offset(y: lineY - 1.5)
                ForEach(HorizonScale.marks, id: \.label) { mark in
                    Text(mark.label)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .offset(x: min(width * HorizonScale.position(daysAway: mark.days) - 5, width - 12), y: lineY - 14)
                }
                ForEach(HorizonLabelPlacer.place(items, width: width)) { placement in
                    Circle()
                        .fill(placement.item.tint)
                        .frame(width: 9, height: 9)
                        .offset(x: placement.dotX - 4.5, y: lineY - 4.5)
                    if let lane = placement.lane {
                        HorizonLabel(item: placement.item)
                            .frame(width: placement.labelWidth, alignment: .leading)
                            .offset(x: placement.labelX, y: lane == 0 ? lineY - 40 : lineY + 9)
                    }
                }
            }
        }
    }
}

private struct HorizonLabel: View {
    let item: HorizonItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.title).font(.system(size: 10, weight: .semibold)).lineLimit(1)
            Text(item.awayText).font(.system(size: 9)).foregroundStyle(.secondary)
        }
    }
}

struct HorizonMediumView: View {
    let snapshot: LabSnapshot

    var body: some View {
        let items = HorizonScale.items(in: snapshot)
        LabTitleBarLayout {
            Text("On the horizon")
        } content: {
            VStack(alignment: .leading, spacing: 4) {
                if items.isEmpty {
                    LabEmptyText("Nothing on the horizon")
                } else {
                    HorizonAxis(items: items)
                }
                if let text = longWeekendText(in: snapshot) {
                    Text(text).font(.caption2.weight(.medium)).foregroundStyle(.red).lineLimit(1)
                }
            }
        }
    }
}

struct HorizonLargeView: View {
    let snapshot: LabSnapshot

    var body: some View {
        let items = HorizonScale.items(in: snapshot)
        LabTitleBarLayout {
            Text("On the horizon")
            Spacer(minLength: 0)
            Text("\(items.count) ahead").fontWeight(.regular)
        } content: {
            VStack(alignment: .leading, spacing: 6) {
                if items.isEmpty {
                    LabEmptyText("Nothing on the horizon")
                } else {
                    HorizonColumn(items: items)
                }
                if let text = longWeekendText(in: snapshot) {
                    Text(text).font(.caption.weight(.medium)).foregroundStyle(.red).lineLimit(1)
                }
            }
        }
    }
}

private struct HorizonColumn: View {
    private static let rowHeight: CGFloat = 32

    let items: [HorizonItem]

    /// Pushes rows down when the log scale would overlap them, then back up from the bottom.
    private func positions(height: CGFloat) -> [CGFloat] {
        var tops = items.map { CGFloat(HorizonScale.position(daysAway: Double($0.daysAway))) * height }
        for index in tops.indices.dropFirst() {
            tops[index] = max(tops[index], tops[index - 1] + Self.rowHeight)
        }
        let lastAllowed = height - Self.rowHeight
        for index in tops.indices.reversed() {
            let limit = lastAllowed - CGFloat(tops.count - 1 - index) * Self.rowHeight
            tops[index] = min(tops[index], limit)
        }
        return tops
    }

    var body: some View {
        GeometryReader { proxy in
            let tops = positions(height: proxy.size.height)
            ZStack(alignment: .topLeading) {
                Capsule().fill(.quaternary).frame(width: 3).padding(.leading, 3)
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 8) {
                        Circle().fill(item.tint).frame(width: 9, height: 9)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(item.title).font(.caption.weight(.semibold)).lineLimit(1)
                            Text(item.date, format: .dateTime.month(.abbreviated).day())
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                        Text(item.awayText).font(.caption.weight(.medium)).foregroundStyle(.secondary)
                    }
                    .offset(y: tops[index])
                }
            }
        }
    }
}
