import SwiftUI

private extension LabSnapshot {
    var nextEventToday: LabEvent? {
        eventsToday.filter { $0.start > now }.min { $0.start < $1.start }
    }
}

struct DayRingSmallView: View {
    let snapshot: LabSnapshot

    var body: some View {
        ZStack {
            DayRingFace(snapshot: snapshot)
            VStack(spacing: 0) {
                Text(LabFormat.time(snapshot.now))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text(leftText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
    }

    private var leftText: String {
        let remaining = snapshot.eventsToday.filter { $0.start > snapshot.now }.count
        return remaining == 0 ? "All clear" : "\(remaining) left"
    }
}

struct DayRingMediumView: View {
    let snapshot: LabSnapshot

    var body: some View {
        HStack(spacing: 14) {
            DayRingFace(snapshot: snapshot).frame(width: 130, height: 130)
            VStack(alignment: .leading, spacing: 5) {
                if let next = snapshot.nextEventToday {
                    Text("Next at \(LabFormat.time(next.start))")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(next.title).font(.subheadline.weight(.semibold)).lineLimit(1)
                } else {
                    Text("Nothing else today").font(.subheadline.weight(.semibold))
                }
                Spacer(minLength: 0)
                if snapshot.lastSleep != nil {
                    legendRow(color: .indigo, text: sleepText)
                }
                if !snapshot.doses.isEmpty {
                    legendRow(color: .teal, text: LabFormat.count(snapshot.doses.count, "dose"))
                }
                if let weather = snapshot.weather(on: snapshot.now) {
                    legendRow(color: .orange, text: "Sun \(LabFormat.time(weather.sunrise))–\(LabFormat.time(weather.sunset))")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
    }

    private var sleepText: String {
        guard let sleep = snapshot.lastSleep else { return "" }
        return "Slept \(LabFormat.duration(minutes: Int(sleep.duration / 60)))"
    }

    private func legendRow(color: Color, text: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
        }
    }
}

struct DayRingCircularView: View {
    let snapshot: LabSnapshot

    var body: some View {
        DayRingFace(snapshot: snapshot, bandWidth: 7, isMonochrome: true)
    }
}
