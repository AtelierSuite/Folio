import Foundation

extension WeatherStore {
    /// Weather for `days`, following the user to any far-away event location on travel days,
    /// plus rain highlights for timed events with coordinates when `detail` includes hours.
    public func snapshot(
        for days: [DateInterval],
        calendar: Calendar,
        events: [CalendarEvent],
        detail: WeatherDetail
    ) async -> WeatherSnapshot {
        guard isEnabled, !days.isEmpty, let home = await homeCoordinate() else { return .empty }
        let dayLocations = WeatherDayLocations().locations(for: days, home: home, events: events)
        let groups = Dictionary(grouping: days) { WeatherLocationKey(dayLocations[$0.start] ?? home) }
        var weatherDays: [Date: WeatherDay] = [:]
        for (location, groupDays) in groups {
            let fetched = await repository.days(groupDays, at: location, detail: detail, calendar: calendar)
            weatherDays.merge(fetched) { $1 }
        }
        let highlights = detail == .dailyAndHourly
            ? await rainHighlights(for: events, calendar: calendar)
            : []
        let attribution = await repository.currentAttribution()
        return WeatherSnapshot(days: weatherDays, rainHighlights: highlights, attribution: attribution)
    }

    private func rainHighlights(for events: [CalendarEvent], calendar: Calendar) async -> [RainHighlight] {
        let finder = RainHighlightFinder()
        let upcoming = finder.candidates(in: events).filter { $0.endDate > now() }
        var requests: [WeatherLocationKey: Set<DateInterval>] = [:]
        for event in upcoming {
            guard let coordinate = event.coordinate,
                  let day = calendar.dateInterval(of: .day, for: event.startDate) else { continue }
            requests[WeatherLocationKey(coordinate), default: []].insert(day)
        }
        var weatherByLocation: [WeatherLocationKey: [Date: WeatherDay]] = [:]
        for (location, days) in requests {
            weatherByLocation[location] = await repository.days(
                Array(days), at: location, detail: .dailyAndHourly, calendar: calendar
            )
        }
        return finder.highlights(for: upcoming) { coordinate, date in
            weatherByLocation[WeatherLocationKey(coordinate)]?[calendar.startOfDay(for: date)]?.hour(containing: date)
        }
    }
}
