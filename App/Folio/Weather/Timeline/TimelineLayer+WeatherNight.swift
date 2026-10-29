import Planner
import SwiftUI

extension TimelineLayer {
    /// Shades the hours before sunrise and after sunset.
    static func weatherNight(_ snapshot: WeatherSnapshot, days: TimelineDays) -> TimelineLayer {
        let nights = days.intervals.flatMap { day -> [DateInterval] in
            guard let daily = snapshot.day(startingAt: day.start)?.daily,
                  let sunrise = daily.sunrise, let sunset = daily.sunset,
                  day.start < sunrise, sunrise < sunset, sunset < day.end else { return [] }
            return [DateInterval(start: day.start, end: sunrise), DateInterval(start: sunset, end: day.end)]
        }
        return .timeBlocks(id: "weather.night", intervals: nights, style: Color.indigo.opacity(0.06))
    }
}
