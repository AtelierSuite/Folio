import Planner
import SwiftUI
import WidgetKit

struct TimelineComplicationView: View {
    let entry: ComplicationEntry

    var body: some View {
        if entry.snapshot.canReadEvents {
            let schedule = HourlySchedule(
                events: entry.snapshot.events,
                at: entry.date,
                calendar: .current,
                hourCount: TimelineComplication.hourCount,
                laneLimit: TimelineComplication.laneLimit
            )
            VStack(alignment: .leading, spacing: 2) {
                TimelineComplicationHours(hours: schedule.hours)
                TimelineComplicationLanes(schedule: schedule)
            }
        } else {
            ComplicationAccessView()
        }
    }
}
