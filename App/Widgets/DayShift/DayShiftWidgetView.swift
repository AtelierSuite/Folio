import Planner
import SwiftUI
import WidgetKit

struct DayShiftWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FolioWidgetEntry

    private var shift: WidgetDayShift {
        entry.snapshot.dayShift(at: entry.date, calendar: .current)
    }

    var body: some View {
        content
            .widgetURL(shift.primaryEvent.map(CalendarDeepLink.url(for:)) ?? CalendarDeepLink.url(forDay: entry.date))
    }

    @ViewBuilder
    private var content: some View {
        if !entry.snapshot.canReadEvents {
            WidgetAccessRequiredView(kind: .event)
        } else if family == .systemMedium {
            DayShiftMediumView(shift: shift)
        } else {
            DayShiftSmallView(shift: shift)
        }
    }
}

struct DayShiftSmallView: View {
    let shift: WidgetDayShift

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            DayShiftHeader(phase: shift.phase)
            DayShiftWeatherLine(weather: shift.weather)
            Spacer(minLength: 0)
            DayShiftPrimaryRow(shift: shift)
            DayShiftFooter(shift: shift)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct DayShiftMediumView: View {
    let shift: WidgetDayShift

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                DayShiftHeader(phase: shift.phase)
                DayShiftWeatherLine(weather: shift.weather)
                if let weather = shift.weather {
                    Text(verbatim: weather.conditionDescription)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                DayShiftFooter(shift: shift)
            }
            .frame(width: 124, alignment: .leading)
            VStack(alignment: .leading, spacing: 6) {
                DayShiftPrimaryRow(shift: shift)
                ForEach(shift.laterEvents) { event in
                    DayShiftEventRow(
                        caption: String(localized: "UpNext.Later", table: "Widgets"),
                        event: event,
                        emptyText: ""
                    )
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
