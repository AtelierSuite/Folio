import SwiftUI

private struct DayColumn: View {
    let day: DayLoad
    let isToday: Bool

    var body: some View {
        VStack(spacing: 3) {
            Text(LabFormat.weekday(day.date))
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(day.isDayOff ? AnyShapeStyle(.red) : AnyShapeStyle(.secondary))
            Text(day.date, format: .dateTime.day())
                .font(.system(size: 13, weight: isToday ? .bold : .regular, design: .rounded))
                .foregroundStyle(isToday ? AnyShapeStyle(.white) : (day.isDayOff ? AnyShapeStyle(.red) : AnyShapeStyle(.primary)))
                .frame(width: 22, height: 22)
                .background { if isToday { Circle().fill(Color("AccentColor")) } }
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    UnevenRoundedRectangle(topLeadingRadius: 3, topTrailingRadius: 3)
                        .fill(Color("AccentColor").opacity(0.35 + 0.65 * WeekLoadCalculator.loadFraction(day)))
                        .frame(height: max(proxy.size.height * WeekLoadCalculator.loadFraction(day), day.eventCount > 0 ? 3 : 0))
                }
                .frame(maxWidth: .infinity)
                .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 3))
            }
            if let weather = day.weather {
                LabWeatherIcon(symbol: weather.symbol)
                    .font(.system(size: 13))
                    .frame(height: 15)
                Text(weather.rainChance >= 0.3 ? "\(Int(weather.rainChance * 100))%" : " ")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.blue)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct WeekColumns: View {
    let snapshot: LabSnapshot

    var body: some View {
        HStack(spacing: 5) {
            ForEach(WeekLoadCalculator.days(in: snapshot)) { day in
                DayColumn(day: day, isToday: snapshot.calendar.isDate(day.date, inSameDayAs: snapshot.now))
            }
        }
    }
}

struct WeekLoadMediumView: View {
    let snapshot: LabSnapshot

    var body: some View {
        WeekColumns(snapshot: snapshot)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
    }
}

struct WeekLoadLargeView: View {
    let snapshot: LabSnapshot

    private var days: [DayLoad] { WeekLoadCalculator.days(in: snapshot) }

    var body: some View {
        LabTitleBarLayout {
            Text("Next 7 days")
            Spacer(minLength: 0)
            if days.contains(where: { $0.busyMinutes > 0 }) {
                Text("\(LabFormat.duration(minutes: days.reduce(0) { $0 + $1.busyMinutes })) booked").fontWeight(.regular)
            }
        } content: {
            VStack(alignment: .leading, spacing: 10) {
                WeekColumns(snapshot: snapshot).frame(height: 170)
                if let heaviest = days.max(by: { $0.busyMinutes < $1.busyMinutes }), heaviest.busyMinutes > 0 {
                    summaryRow(symbol: "flame.fill", color: .orange, title: "Heaviest", day: heaviest)
                    ForEach(snapshot.events(on: heaviest.date).prefix(3)) { event in
                        HStack(spacing: 6) {
                            LabColorBar(color: event.tint)
                            Text(event.title).font(.caption2.weight(.medium))
                            Spacer(minLength: 0)
                            Text(LabFormat.time(event.start)).font(.caption2).foregroundStyle(.secondary)
                        }
                        .lineLimit(1)
                        .padding(.leading, 6)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    if let lightest = days.filter({ !$0.isDayOff }).min(by: { $0.busyMinutes < $1.busyMinutes }) {
                        summaryRow(symbol: "leaf.fill", color: .green, title: "Most open", day: lightest)
                    }
                } else {
                    Text("A clear week ahead").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }

    private func summaryRow(symbol: String, color: Color, title: String, day: DayLoad) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol).foregroundStyle(color).frame(width: 16)
            Text("\(title): \(LabFormat.weekday(day.date))").fontWeight(.semibold)
            Spacer(minLength: 0)
            Text("\(LabFormat.duration(minutes: day.busyMinutes)) · \(LabFormat.count(day.eventCount, "event"))").foregroundStyle(.secondary)
        }
        .font(.caption)
    }
}
