import Planner
import SwiftUI
import WidgetKit

struct DayShiftHeader: View {
    let phase: WidgetDayPhase

    private var title: String {
        switch phase {
        case .morning: String(localized: "DayShift.Morning", table: "Widgets")
        case .daytime: String(localized: "DayShift.Daytime", table: "Widgets")
        case .evening: String(localized: "DayShift.Evening", table: "Widgets")
        }
    }

    private var symbol: String {
        switch phase {
        case .morning: "sunrise.fill"
        case .daytime: "sun.max.fill"
        case .evening: "moon.stars.fill"
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: symbol)
            Text(verbatim: title)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(phase == .evening ? .indigo : .orange)
        .lineLimit(1)
        .widgetAccentable()
    }
}

/// Palette colors, because multicolor clouds are white and vanish on a light widget.
struct DayShiftWeatherLine: View {
    private static let rainThreshold = 0.3

    let weather: DailyWeather?

    var body: some View {
        if let weather {
            HStack(spacing: 4) {
                Image(systemName: weather.symbolName)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        weather.symbolName.hasPrefix("cloud") ? .gray : .orange,
                        weather.symbolName.contains("rain") ? .blue : .orange
                    )
                Text(verbatim: temperatures(weather))
                    .monospacedDigit()
                if weather.precipitationChance >= Self.rainThreshold {
                    Text(weather.precipitationChance, format: .percent.precision(.fractionLength(0)))
                        .foregroundStyle(.blue)
                }
            }
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(weather.conditionDescription)
        }
    }

    private func temperatures(_ weather: DailyWeather) -> String {
        let high = WidgetWeatherSlot.temperature(weather.highCelsius)
        return "\(high) / \(WidgetWeatherSlot.temperature(weather.lowCelsius))"
    }
}

struct DayShiftPrimaryRow: View {
    let shift: WidgetDayShift

    private var caption: String {
        switch shift.phase {
        case .morning: String(localized: "DayShift.FirstUp", table: "Widgets")
        case .daytime: String(localized: "DayShift.Next", table: "Widgets")
        case .evening: String(localized: "DayShift.Tomorrow", table: "Widgets")
        }
    }

    private var emptyText: String {
        shift.phase == .daytime
            ? String(localized: "DayShift.AllClear", table: "Widgets")
            : String(localized: "DayShift.NothingPlanned", table: "Widgets")
    }

    var body: some View {
        DayShiftEventRow(caption: caption, event: shift.primaryEvent, emptyText: emptyText)
    }
}

struct DayShiftEventRow: View {
    let caption: String
    let event: CalendarEvent?
    let emptyText: String

    var body: some View {
        HStack(spacing: 6) {
            WidgetColorBar(color: event?.color ?? .gray)
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: caption)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(verbatim: event?.title ?? emptyText)
                    .font(.caption.weight(.semibold))
                if let event {
                    Text(verbatim: WidgetEventTimeText.time(event.startDate))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(1)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct DayShiftFooter: View {
    let shift: WidgetDayShift

    var body: some View {
        Group {
            if shift.phase == .evening {
                if let alarm = shift.alarmDate {
                    HStack(spacing: 3) {
                        Image(systemName: "alarm.fill")
                        Text(verbatim: WidgetEventTimeText.time(alarm))
                    }
                } else {
                    Text(verbatim: String(localized: "DayShift.NoAlarm", table: "Widgets"))
                }
            } else if shift.remainingCount == 0 {
                Text(verbatim: String(localized: "DayShift.NothingLeft", table: "Widgets"))
            } else {
                Text(verbatim: String(
                    format: String(localized: "DayShift.Remaining %lld", table: "Widgets"), shift.remainingCount
                ))
            }
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
}
