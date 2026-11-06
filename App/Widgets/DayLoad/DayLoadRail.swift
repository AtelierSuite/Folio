import Planner
import SwiftUI
import WidgetKit

/// The day's window as one bar: open time in green, busy time in grey and a mark for now.
struct DayLoadRail: View {
    let dayLoad: WidgetDayLoad
    let date: Date

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Rectangle().fill(.green.opacity(0.25))
                ForEach(dayLoad.busyIntervals, id: \.start) { busy in
                    Rectangle()
                        .fill(.secondary)
                        .frame(width: max(width * (share(of: busy.end) - share(of: busy.start)), 1))
                        .offset(x: width * share(of: busy.start))
                }
                if dayLoad.window.contains(date) {
                    Rectangle()
                        .fill(.tint)
                        .frame(width: 2)
                        .offset(x: width * share(of: date) - 1)
                        .widgetAccentable()
                }
            }
            .clipShape(.capsule)
        }
    }

    private func share(of date: Date) -> Double {
        guard dayLoad.window.duration > 0 else { return 0 }
        return min(max(date.timeIntervalSince(dayLoad.window.start) / dayLoad.window.duration, 0), 1)
    }
}
