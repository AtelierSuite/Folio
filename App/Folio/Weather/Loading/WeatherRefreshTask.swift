#if os(iOS)
import BackgroundTasks
import Planner
import SwiftUI
import WidgetKit

nonisolated enum WeatherRefreshTask {
    static let identifier = "com.tsubuzaki.Folio.weather.refresh"

    static func schedule(calendar: Calendar = .current) {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = WeatherRefreshSchedule.nextRunDate(after: .now, calendar: calendar)
        try? BGTaskScheduler.shared.submit(request)
    }

    static func cancel() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
    }
}

extension Scene {
    func weatherRefreshTask(_ store: WeatherStore) -> some Scene {
        backgroundTask(.appRefresh(WeatherRefreshTask.identifier)) {
            WeatherRefreshTask.schedule()
            if await store.refreshWidgetForecast(calendar: .current) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}

private struct WeatherRefreshScheduling: ViewModifier {
    let store: WeatherStore
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content.onChange(of: scenePhase) { _, phase in
            guard phase == .background else { return }
            if store.isEnabled {
                WeatherRefreshTask.schedule()
            } else {
                WeatherRefreshTask.cancel()
            }
        }
    }
}

extension View {
    func schedulesWeatherRefresh(_ store: WeatherStore) -> some View {
        modifier(WeatherRefreshScheduling(store: store))
    }
}
#else
import Planner
import SwiftUI

extension Scene {
    func weatherRefreshTask(_ store: WeatherStore) -> some Scene {
        self
    }
}

extension View {
    func schedulesWeatherRefresh(_ store: WeatherStore) -> some View {
        self
    }
}
#endif
