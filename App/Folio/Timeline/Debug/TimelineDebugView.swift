#if DEBUG
import Planner
import SwiftUI

struct TimelineDebugView: View {
    @State private var dayCount = 7
    @State private var scenario = TimelineDebugScenario.fallBack
    @State private var dayOffset = 0
    @State private var zoom = TimelineZoomController(storageKey: nil)

    var body: some View {
        let calendar = scenario.calendar
        let sampleWeek = TimelineDebugSampleWeek(
            weekStart: scenario.weekStart,
            calendar: calendar,
            floatingSourceTimeZone: .current
        )
        let firstDay = calendar.date(byAdding: .day, value: dayOffset, to: sampleWeek.weekStart) ?? sampleWeek.weekStart
        let days = TimelineDays(startingOn: firstDay, count: dayCount, calendar: calendar)
        VStack(spacing: 0) {
            TimelineDebugControlsView(
                dayCount: $dayCount,
                scenario: $scenario,
                dayOffset: $dayOffset,
                hourHeight: Binding(get: { zoom.hourHeight }, set: { zoom.setHourHeight($0) })
            )
            CalendarTimelineView(
                layout: TimelineLayoutEngine(days: days).layout(sampleWeek.entries),
                pages: TimelinePages(single: days),
                position: .constant(ScrollPosition(id: firstDay)),
                zoom: zoom,
                layers: [
                    .timeBlocks(id: "sleep", intervals: sampleWeek.sleepIntervals, style: Color.indigo.opacity(0.08)),
                    .secondaryTimeZone(TimeZone(identifier: "Asia/Tokyo") ?? .gmt)
                ]
            )
        }
        .navigationTitle(String(localized: "Debug.Title", table: "Timeline"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onChange(of: scenario) { dayOffset = 0 }
    }
}
#endif
