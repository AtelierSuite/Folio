import Planner
import SwiftUI
import WidgetKit

#if os(iOS)
struct WeatherUpNextWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    var body: some View {
        content
            .widgetURL(upNext.map { CalendarDeepLink.url(for: $0.event) } ?? CalendarDeepLink.url(forDay: entry.date))
    }

    private var upNext: WidgetUpNext? {
        entry.snapshot.upNext(at: entry.date)
    }

    private var weather: DailyWeather? {
        entry.snapshot.weather(on: entry.date, calendar: .current)
    }

    @ViewBuilder
    private var content: some View {
        if !entry.snapshot.canReadEvents {
            WidgetAccessoryAccessRequiredView(systemImage: "calendar")
        } else if let weather {
            switch family {
            case .accessoryInline:
                WeatherUpNextInlineView(
                    weather: weather,
                    upNext: upNext,
                    date: entry.date,
                    showsDetails: entry.showsDetails
                )
            default:
                WeatherUpNextRectangularView(
                    weather: weather,
                    upNext: upNext,
                    date: entry.date,
                    showsDetails: entry.showsDetails
                )
            }
        } else {
            switch family {
            case .accessoryInline:
                UpNextInlineView(upNext: upNext, date: entry.date, showsDetails: entry.showsDetails)
            default:
                UpNextRectangularView(upNext: upNext, date: entry.date, showsDetails: entry.showsDetails)
            }
        }
    }
}
#endif
