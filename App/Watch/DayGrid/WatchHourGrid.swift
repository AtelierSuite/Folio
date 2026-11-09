import Planner
import SwiftUI

struct WatchHourGrid: View {
    static let hourHeight: CGFloat = 44
    static let labelWidth: CGFloat = 24
    static let labelSpacing: CGFloat = 2
    static let workingDayStartHour = 8.0
    private static let hours = 0..<Int(TimelineDays.hoursPerDay)

    let layout: TimelineLayout
    let eventsByID: [String: CalendarEvent]
    let now: Date

    static func hourID(_ hour: Int) -> String {
        "hour-\(hour)"
    }

    var body: some View {
        HStack(alignment: .top, spacing: Self.labelSpacing) {
            WatchHourLabels(firstDay: layout.days.intervals.first?.start ?? now, hours: Self.hours)
            GeometryReader { geometry in
                let columnWidth = geometry.size.width / CGFloat(max(layout.days.count, 1))
                ZStack(alignment: .topLeading) {
                    WatchHourLines(hours: Self.hours, dayCount: layout.days.count, columnWidth: columnWidth)
                    ForEach(layout.timedPlacements) { placement in
                        placementView(placement, columnWidth: columnWidth)
                    }
                    if let position = layout.days.position(of: now) {
                        WatchNowLine()
                            .frame(width: columnWidth)
                            .offset(
                                x: columnWidth * CGFloat(position.dayIndex),
                                y: CGFloat(position.hour) * Self.hourHeight - WatchNowLine.height / 2
                            )
                    }
                }
            }
        }
        .frame(height: CGFloat(Self.hours.count) * Self.hourHeight)
    }

    @ViewBuilder
    private func placementView(_ placement: TimelineTimedPlacement, columnWidth: CGFloat) -> some View {
        let height = CGFloat(placement.endHour - placement.startHour) * Self.hourHeight
        let block = WatchEventBlock(entry: placement.entry, height: height)
            .frame(width: columnWidth * placement.widthFraction, height: height)
            .offset(
                x: columnWidth * (CGFloat(placement.dayIndex) + placement.leadingFraction),
                y: CGFloat(placement.startHour) * Self.hourHeight
            )
        if let event = eventsByID[placement.entry.id] {
            NavigationLink(value: event) { block }
                .buttonStyle(.plain)
        } else {
            block
        }
    }
}
