import Foundation

extension WeatherStore {
    /// Fetches today's and tomorrow's hourly weather where the widgets read it, without asking for a
    /// new location fix, so it works from a background task.
    @discardableResult
    public func refreshWidgetForecast(calendar: Calendar) async -> Bool {
        guard isEnabled, let home = widgetHomeCoordinate else { return false }
        let today = calendar.startOfDay(for: now())
        let days = (0..<2).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today).flatMap { calendar.dateInterval(of: .day, for: $0) }
        }
        let location = WeatherLocationKey(home)
        let fetched = await repository.days(days, at: location, detail: .dailyAndHourly, calendar: calendar)
        return fetched[today]?.hourly.isEmpty == false
    }

    private var widgetHomeCoordinate: PlannerCoordinate? {
        switch locationMode {
        case .chosen: chosenPlace?.coordinate
        case .current: settings.lastLocationFix?.coordinate
        }
    }
}
