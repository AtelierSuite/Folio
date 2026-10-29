import Planner
import SwiftUI

extension TimelineLayer {
    static func weatherBand(_ snapshot: WeatherSnapshot) -> TimelineLayer {
        TimelineLayer(id: "weather.band", placement: .belowEntries) { context in
            TimelineWeatherBandView(snapshot: snapshot, context: context)
        }
    }
}

/// A narrow strip on the trailing edge of each day: rain chance as a blue tint, and the
/// temperature each hour when the columns are wide enough to fit it.
struct TimelineWeatherBandView: View {
    let snapshot: WeatherSnapshot
    let context: TimelineLayerContext

    private var showsTemperatures: Bool {
        context.days.count <= 3
    }

    private var labelEveryHours: Int {
        context.hourHeight >= 36 ? 1 : 2
    }

    var body: some View {
        TimelineSlotLayout(dayCount: context.days.count, hourHeight: context.hourHeight) {
            ForEach(hours, id: \.hour.date) { item in
                TimelineWeatherBandHourView(
                    hour: item.hour,
                    showsTemperature: showsTemperatures && item.wholeHour % labelEveryHours == 0
                )
                .timelineSlot(
                    TimelineSlot(dayIndex: item.dayIndex, startHour: item.startHour, endHour: item.startHour + 1)
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var hours: [BandHour] {
        context.days.intervals.enumerated().flatMap { dayIndex, day in
            (snapshot.day(startingAt: day.start)?.hourly ?? []).map { hour in
                let startHour = context.days.hour(of: hour.date, onDay: dayIndex)
                return BandHour(dayIndex: dayIndex, startHour: startHour, wholeHour: Int(startHour), hour: hour)
            }
        }
    }

    private struct BandHour {
        let dayIndex: Int
        let startHour: Double
        let wholeHour: Int
        let hour: HourlyWeather
    }
}

struct TimelineWeatherBandHourView: View {
    let hour: HourlyWeather
    let showsTemperature: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 2) {
            if showsTemperature {
                Text(WeatherFormatting.temperature(hour.temperatureCelsius))
                    .font(.system(size: 9))
                    .monospacedDigit()
                    .foregroundStyle(.tertiary)
                    .padding(.top, 1)
            }
            Rectangle()
                .fill(Color.blue.opacity(0.08 + hour.precipitationChance * 0.5))
                .frame(width: 3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}
