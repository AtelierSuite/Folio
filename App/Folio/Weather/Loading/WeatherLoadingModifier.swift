import Planner
import SwiftUI

struct WeatherLoadingModifier: ViewModifier {
    @Environment(WeatherStore.self) private var store
    @Environment(\.platformCapabilities) private var capabilities
    let days: [DateInterval]
    let calendar: Calendar
    let events: [CalendarEvent]
    let detail: WeatherDetail
    @Binding var snapshot: WeatherSnapshot

    func body(content: Content) -> some View {
        content
            .task(id: LoadKey(days: days, events: events, revision: store.revision)) {
                guard capabilities.supports(.weather) else {
                    snapshot = .empty
                    return
                }
                snapshot = await store.snapshot(for: days, calendar: calendar, events: events, detail: detail)
            }
    }

    private struct LoadKey: Equatable {
        let days: [DateInterval]
        let events: [CalendarEvent]
        let revision: Int
    }
}

extension View {
    func loadsWeather(
        for days: [DateInterval],
        calendar: Calendar,
        events: [CalendarEvent],
        detail: WeatherDetail,
        into snapshot: Binding<WeatherSnapshot>
    ) -> some View {
        modifier(WeatherLoadingModifier(
            days: days, calendar: calendar, events: events, detail: detail, snapshot: snapshot
        ))
    }
}
