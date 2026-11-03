import Planner
import SwiftUI

struct StandaloneAlarmTimelineLayerView: View {
    @Environment(StandaloneAlarmCenter.self) private var center
    let context: TimelineLayerContext

    var body: some View {
        TimelineSlotLayout(dayCount: context.days.count, hourHeight: context.hourHeight) {
            ForEach(markers, id: \.alarm.id) { marker in
                StandaloneAlarmMarkerView(alarm: marker.alarm)
                    .timelineSlot(marker.slot)
            }
        }
    }

    private var markers: [(alarm: StandaloneAlarm, slot: TimelineSlot)] {
        guard let span = context.days.span else { return [] }
        let halfHeight = Double(StandaloneAlarmMarkerView.height / 2 / max(context.hourHeight, 1))
        return center.alarms(in: span).compactMap { alarm in
            guard let position = context.days.position(of: alarm.fireDate) else { return nil }
            let slot = TimelineSlot(
                dayIndex: position.dayIndex,
                startHour: position.hour - halfHeight,
                endHour: position.hour + halfHeight
            )
            return (alarm, slot)
        }
    }
}
