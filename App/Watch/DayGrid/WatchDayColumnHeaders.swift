import Planner
import SwiftUI

struct WatchDayColumnHeaders: View {
    let days: TimelineDays

    var body: some View {
        HStack(spacing: 0) {
            Color.clear
                .frame(width: WatchHourGrid.labelWidth + WatchHourGrid.labelSpacing)
            ForEach(days.intervals, id: \.start) { interval in
                let isToday = Calendar.current.isDateInToday(interval.start)
                Text(interval.start.formatted(.dateTime.weekday(.abbreviated).day()))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(isToday ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
