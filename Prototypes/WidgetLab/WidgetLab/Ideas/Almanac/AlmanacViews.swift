import SwiftUI

private extension LabSnapshot {
    var dayColor: Color {
        if holiday(on: now) != nil { return .red }
        switch calendar.component(.weekday, from: now) {
        case 1: return .red
        case 7: return .blue
        default: return .primary
        }
    }
}

private struct BindingHoles: View {
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

private struct AlmanacHeader: View {
    let date: Date

    var body: some View {
        ZStack {
            HStack {
                Text(date, format: .dateTime.year())
                Spacer()
                Text(date, format: .dateTime.month(.abbreviated))
            }
            .font(.system(size: 10, weight: .semibold, design: .serif))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            BindingHoles()
        }
        .frame(height: 24)
        .frame(maxWidth: .infinity)
        .background(Color("AccentColor"))
    }
}

private struct AlmanacDayNumber: View {
    let snapshot: LabSnapshot
    let size: CGFloat

    var body: some View {
        VStack(spacing: -2) {
            Text(snapshot.now, format: .dateTime.day())
                .font(.system(size: size, weight: .bold, design: .serif))
                .foregroundStyle(snapshot.dayColor)
            Text(snapshot.now, format: .dateTime.weekday(.wide))
                .font(.system(size: 11, weight: .medium, design: .serif))
                .foregroundStyle(snapshot.dayColor)
        }
    }
}

struct AlmanacSmallView: View {
    let snapshot: LabSnapshot

    var body: some View {
        VStack(spacing: 0) {
            AlmanacHeader(date: snapshot.now)
            Spacer(minLength: 0)
            AlmanacDayNumber(snapshot: snapshot, size: 56)
            Spacer(minLength: 0)
            Text("\(LabFormat.japaneseEra(snapshot.now)) · \(LabFormat.lunarDate(snapshot.now))")
                .font(.system(size: 9, design: .serif))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 8)
                .padding(.bottom, 10)
        }
    }
}

struct AlmanacMediumView: View {
    let snapshot: LabSnapshot

    var body: some View {
        VStack(spacing: 0) {
            AlmanacHeader(date: snapshot.now)
            HStack(spacing: 12) {
                AlmanacDayNumber(snapshot: snapshot, size: 60)
                    .frame(width: 104)
                Rectangle()
                    .fill(.quaternary)
                    .frame(width: 1)
                    .padding(.vertical, 12)
                facts
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.trailing, 12)
        }
    }

    private var facts: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(LabFormat.japaneseEra(snapshot.now))
            Text(LabFormat.lunarDate(snapshot.now))
            if let holiday = snapshot.holiday(on: snapshot.now) {
                Text(holiday.name).foregroundStyle(.red)
            }
            if let weather = snapshot.weather(on: snapshot.now) {
                HStack(spacing: 4) {
                    LabWeatherIcon(symbol: weather.symbol)
                    Text("\(weather.high)° / \(weather.low)°")
                }
                HStack(spacing: 4) {
                    LabWeatherIcon(symbol: "sunrise.fill")
                    Text("\(LabFormat.time(weather.sunrise))–\(LabFormat.time(weather.sunset))")
                }
            }
            Text(LabFormat.count(snapshot.eventsToday.count, "event")).fontWeight(.semibold)
        }
        .font(.system(size: 11, design: .serif))
        .lineLimit(1)
    }
}
