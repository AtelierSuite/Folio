import Planner
import SwiftUI
import WidgetKit

struct TimelineComplicationLanes: View {
    private static let laneHeight: CGFloat = 15
    private static let laneSpacing: CGFloat = 2

    let schedule: HourlySchedule

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .topLeading) {
                if schedule.strips.isEmpty {
                    Text(String(localized: "Timeline.Free", table: "Complications"))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                ForEach(schedule.strips) { strip in
                    TimelineComplicationStrip(event: strip.event)
                        .frame(
                            width: max(width * (strip.endFraction - strip.startFraction), 3),
                            height: Self.laneHeight
                        )
                        .offset(
                            x: width * strip.startFraction,
                            y: CGFloat(strip.lane) * (Self.laneHeight + Self.laneSpacing)
                        )
                }
                Rectangle()
                    .fill(.red)
                    .frame(width: 1.5)
                    .offset(x: width * schedule.nowFraction)
                    .widgetAccentable()
            }
        }
        .frame(height: CGFloat(TimelineComplication.laneLimit) * (Self.laneHeight + Self.laneSpacing))
    }
}
