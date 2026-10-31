import Planner
import SwiftUI

extension TimelineLayer {
    /// Shades the hours before sunrise and after sunset, fading across each.
    static func weatherNight(_ snapshot: WeatherSnapshot) -> TimelineLayer {
        TimelineLayer(id: "weather.night", placement: .belowEntries) { context in
            WeatherNightView(
                daylights: WeatherNightDaylight.daylights(in: snapshot, days: context.days),
                context: context
            )
        }
    }
}

struct WeatherNightDaylight: Hashable {
    let dayIndex: Int
    let sunriseHour: Double
    let sunsetHour: Double

    static func daylights(in snapshot: WeatherSnapshot, days: TimelineDays) -> [WeatherNightDaylight] {
        days.intervals.enumerated().compactMap { dayIndex, day in
            guard let daily = snapshot.day(startingAt: day.start)?.daily,
                  let sunrise = daily.sunrise, let sunset = daily.sunset,
                  day.start < sunrise, sunrise < sunset, sunset < day.end else { return nil }
            return WeatherNightDaylight(
                dayIndex: dayIndex,
                sunriseHour: days.hour(of: sunrise, onDay: dayIndex),
                sunsetHour: days.hour(of: sunset, onDay: dayIndex)
            )
        }
    }
}

struct WeatherNightView: View {
    static let nightColor = Color.indigo.opacity(0.06)
    static let dayColor = Color.indigo.opacity(0)
    static let fadeHours = 1.0

    let daylights: [WeatherNightDaylight]
    let context: TimelineLayerContext

    var body: some View {
        TimelineSlotLayout(dayCount: context.days.count, hourHeight: context.hourHeight) {
            ForEach(daylights, id: \.self) { daylight in
                Rectangle()
                    .fill(LinearGradient(stops: stops(for: daylight), startPoint: .top, endPoint: .bottom))
                    .timelineSlot(TimelineSlot(dayIndex: daylight.dayIndex, startHour: 0, endHour: 24))
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func stops(for daylight: WeatherNightDaylight) -> [Gradient.Stop] {
        let halfFade = Self.fadeHours / 2
        let midday = (daylight.sunriseHour + daylight.sunsetHour) / 2
        let hours = [
            max(daylight.sunriseHour - halfFade, 0),
            min(daylight.sunriseHour + halfFade, midday),
            max(daylight.sunsetHour - halfFade, midday),
            min(daylight.sunsetHour + halfFade, 24)
        ]
        let colors = [Self.nightColor, Self.dayColor, Self.dayColor, Self.nightColor]
        return zip(hours, colors).map { hour, color in
            Gradient.Stop(color: color, location: hour / 24)
        }
    }
}
