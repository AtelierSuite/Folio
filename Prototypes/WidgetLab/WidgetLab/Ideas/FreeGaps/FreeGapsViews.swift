import SwiftUI

private struct FreeHeadline {
    var caption: String
    var value: String
    var isFree: Bool
}

private extension LabSnapshot {
    var freeHeadline: FreeHeadline {
        switch FreeGapFinder.state(in: self) {
        case .free(let until):
            FreeHeadline(caption: "Free until \(LabFormat.time(until))", value: remaining(until: until), isFree: true)
        case .busy(let until):
            FreeHeadline(caption: "Busy until \(LabFormat.time(until))", value: remaining(until: until), isFree: false)
        case .dayOver:
            FreeHeadline(caption: "Day's done", value: "—", isFree: true)
        }
    }

    private func remaining(until date: Date) -> String {
        LabFormat.duration(minutes: LabFormat.minutes(from: now, to: date))
    }
}

struct DayRail: View {
    let snapshot: LabSnapshot

    private var window: DateInterval {
        FreeGapFinder.window(on: snapshot.now, calendar: snapshot.calendar)
    }

    private func share(_ date: Date) -> Double {
        min(max(date.timeIntervalSince(window.start) / window.duration, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(.green.opacity(0.25))
                ForEach(FreeGapFinder.busyIntervals(snapshot.eventsToday, in: window), id: \.start) { busy in
                    Rectangle()
                        .fill(.secondary)
                        .frame(width: max(width * (share(busy.end) - share(busy.start)), 1))
                        .offset(x: width * share(busy.start))
                }
                if window.contains(snapshot.now) {
                    Rectangle()
                        .fill(Color("AccentColor"))
                        .frame(width: 2, height: proxy.size.height + 4)
                        .offset(x: width * share(snapshot.now) - 1)
                }
            }
            .clipShape(.capsule)
        }
    }
}

struct FreeGapsSmallView: View {
    let snapshot: LabSnapshot

    var body: some View {
        let headline = snapshot.freeHeadline
        VStack(alignment: .leading, spacing: 2) {
            Text(headline.caption)
                .font(.caption.weight(.semibold))
                .foregroundStyle(headline.isFree ? .green : .secondary)
                .lineLimit(1)
            Text(headline.value)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Spacer(minLength: 0)
            if let longest = FreeGapFinder.gaps(in: snapshot).max(by: { $0.duration < $1.duration }) {
                Text("Longest \(LabFormat.time(longest.start)), \(LabFormat.duration(minutes: Int(longest.duration / 60)))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            DayRail(snapshot: snapshot).frame(height: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
    }
}

struct FreeGapsMediumView: View {
    let snapshot: LabSnapshot

    var body: some View {
        let allGaps = FreeGapFinder.gaps(in: snapshot)
        let gaps = Array(allGaps.prefix(3))
        LabTitleBarLayout {
            Text(snapshot.freeHeadline.caption)
            Spacer(minLength: 0)
            Text("\(LabFormat.count(allGaps.count, "gap")) left").fontWeight(.regular)
        } content: {
            VStack(spacing: 5) {
                if gaps.isEmpty {
                    LabEmptyText("No free time left today")
                } else {
                    ForEach(gaps, id: \.start) { GapRow(gap: $0) }
                }
                Spacer(minLength: 0)
                DayRail(snapshot: snapshot).frame(height: 8)
            }
        }
    }
}

private struct GapRow: View {
    let gap: DateInterval

    var body: some View {
        HStack(spacing: 6) {
            LabColorBar(color: .green)
            Text("\(LabFormat.time(gap.start))–\(LabFormat.time(gap.end))")
                .font(.caption.weight(.semibold))
                .monospacedDigit()
            Text(LabFormat.duration(minutes: Int(gap.duration / 60)))
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Image(systemName: "plus.circle.fill")
                .font(.subheadline)
                .foregroundStyle(Color("AccentColor"))
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct FreeGapsRectangularView: View {
    let snapshot: LabSnapshot

    var body: some View {
        let headline = snapshot.freeHeadline
        VStack(alignment: .leading, spacing: 3) {
            Text(headline.caption).font(.headline).lineLimit(1).minimumScaleFactor(0.8)
            Text("\(headline.value) from now").font(.caption).opacity(0.7)
            DayRail(snapshot: snapshot).frame(height: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct FreeGapsInlineView: View {
    let snapshot: LabSnapshot

    var body: some View {
        let headline = snapshot.freeHeadline
        Text(headline.isFree ? "Free for \(headline.value)" : "Busy for \(headline.value)")
            .font(.subheadline)
            .lineLimit(1)
    }
}
