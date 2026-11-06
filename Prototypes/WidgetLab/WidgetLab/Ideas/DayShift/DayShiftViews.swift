import SwiftUI

private extension LabSnapshot {
    var phase: DayPhase { DayPhase.phase(at: now, calendar: calendar) }
    var tomorrow: Date { calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now }
    var remainingToday: [LabEvent] {
        eventsToday.filter { $0.start > now }.sorted { $0.start < $1.start }
    }
    var firstEventToday: LabEvent? { eventsToday.min { $0.start < $1.start } }
    var firstEventTomorrow: LabEvent? { events(on: tomorrow).min { $0.start < $1.start } }
}

private struct ShiftEventRow: View {
    let caption: String
    let event: LabEvent?
    let emptyText: String

    var body: some View {
        HStack(spacing: 6) {
            LabColorBar(color: event?.tint ?? .secondary)
            VStack(alignment: .leading, spacing: 0) {
                Text(caption).font(.caption2).foregroundStyle(.secondary)
                Text(event?.title ?? emptyText).font(.caption.weight(.semibold))
                if let event {
                    Text(LabFormat.time(event.start)).font(.caption2).foregroundStyle(.secondary)
                }
            }
            .lineLimit(1)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct ShiftWeatherLine: View {
    let weather: LabWeather?

    var body: some View {
        if let weather {
            HStack(spacing: 4) {
                LabWeatherIcon(symbol: weather.symbol)
                Text("\(weather.high)° / \(weather.low)°")
                if weather.rainChance >= 0.3 {
                    Text("\(Int(weather.rainChance * 100))%").foregroundStyle(.blue)
                }
            }
            .font(.caption.weight(.medium))
        }
    }
}

private struct ShiftContent: View {
    let snapshot: LabSnapshot

    var body: some View {
        switch snapshot.phase {
        case .morning:
            ShiftEventRow(caption: "First up", event: snapshot.firstEventToday, emptyText: "Nothing planned")
        case .daytime:
            ShiftEventRow(caption: "Next", event: snapshot.remainingToday.first, emptyText: "All clear")
        case .evening:
            ShiftEventRow(caption: "Tomorrow", event: snapshot.firstEventTomorrow, emptyText: "Nothing planned")
        }
    }
}

private struct ShiftHeader: View {
    let snapshot: LabSnapshot

    private var title: String {
        switch snapshot.phase {
        case .morning: "Good morning"
        case .daytime: "This afternoon"
        case .evening: "Wind down"
        }
    }

    private var symbol: String {
        switch snapshot.phase {
        case .morning: "sunrise.fill"
        case .daytime: "sun.max.fill"
        case .evening: "moon.stars.fill"
        }
    }

    var body: some View {
        Label(title, systemImage: symbol)
            .labelStyle(TightLabelStyle())
            .font(.caption.weight(.semibold))
            .foregroundStyle(snapshot.phase == .evening ? .indigo : .orange)
            .lineLimit(1)
    }
}

private struct ShiftFooter: View {
    let snapshot: LabSnapshot

    var body: some View {
        Group {
            switch snapshot.phase {
            case .morning, .daytime:
                if snapshot.remainingToday.isEmpty {
                    Text("Nothing left today")
                } else {
                    Text("\(LabFormat.count(snapshot.remainingToday.count, "event")) left today")
                }
            case .evening:
                if let alarm = snapshot.wakeUpAlarm {
                    Label("Alarm \(LabFormat.time(alarm))", systemImage: "alarm.fill")
                        .labelStyle(TightLabelStyle())
                } else {
                    Text("No alarm set")
                }
            }
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
}

struct DayShiftSmallView: View {
    let snapshot: LabSnapshot

    private var weather: LabWeather? {
        snapshot.weather(on: snapshot.phase == .evening ? snapshot.tomorrow : snapshot.now)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ShiftHeader(snapshot: snapshot)
            ShiftWeatherLine(weather: weather)
            Spacer(minLength: 0)
            ShiftContent(snapshot: snapshot)
            ShiftFooter(snapshot: snapshot)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
    }
}

struct DayShiftMediumView: View {
    let snapshot: LabSnapshot

    private var weather: LabWeather? {
        snapshot.weather(on: snapshot.phase == .evening ? snapshot.tomorrow : snapshot.now)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                ShiftHeader(snapshot: snapshot)
                ShiftWeatherLine(weather: weather)
                if let weather {
                    Text(weather.condition).font(.caption2).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                ShiftFooter(snapshot: snapshot)
            }
            .frame(width: 124, alignment: .leading)
            VStack(alignment: .leading, spacing: 6) {
                ShiftContent(snapshot: snapshot)
                if snapshot.phase != .evening {
                    ForEach(snapshot.remainingToday.dropFirst(snapshot.phase == .daytime ? 1 : 0).prefix(2)) { event in
                        ShiftEventRow(caption: "Later", event: event, emptyText: "")
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
    }
}
