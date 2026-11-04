import Planner
import SwiftUI

struct HourlyScheduleGrid: View {
    private static let labelHeight: CGFloat = 14
    private static let laneSpacing: CGFloat = 3

    let schedule: HourlySchedule

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let laneHeight = laneHeight(in: geometry.size.height)
            ZStack(alignment: .topLeading) {
                HourlyHourColumns(hours: schedule.hours, hiddenCount: schedule.hiddenCount)
                ForEach(schedule.strips) { strip in
                    HourlyEventStrip(event: strip.event)
                        .frame(width: stripWidth(strip, in: width), height: laneHeight)
                        .offset(
                            x: strip.startFraction * width,
                            y: Self.labelHeight + CGFloat(strip.lane) * (laneHeight + Self.laneSpacing)
                        )
                }
                if schedule.strips.isEmpty {
                    WidgetEmptyText(text: String(localized: "Hourly.Empty", table: "Widgets"))
                        .padding(.top, Self.labelHeight)
                }
                HourlyNowLine()
                    .offset(x: schedule.nowFraction * width)
            }
        }
    }

    private func laneHeight(in height: CGFloat) -> CGFloat {
        let laneCount = CGFloat(HourlySchedule.defaultLaneLimit)
        return max((height - Self.labelHeight - Self.laneSpacing * (laneCount - 1)) / laneCount, 0)
    }

    private func stripWidth(_ strip: HourlySchedule.Strip, in width: CGFloat) -> CGFloat {
        max((strip.endFraction - strip.startFraction) * width - 1, 0)
    }
}
