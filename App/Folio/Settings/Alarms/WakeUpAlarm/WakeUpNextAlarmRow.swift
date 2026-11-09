import Planner
import SwiftUI

struct WakeUpNextAlarmRow: View {
    let alarm: WakeUpAlarm?

    var body: some View {
        LabeledContent(String(localized: "Next", table: "WakeUpAlarms")) {
            if let alarm {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(alarm.fireDate.formatted(.dateTime.weekday(.abbreviated).hour().minute()))
                    Text(alarm.event.title)
                        .font(.caption)
                        .lineLimit(1)
                    if let travelTime = alarm.travelTime {
                        Text(travelText(travelTime))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text(String(localized: "Next.None", table: "WakeUpAlarms"))
            }
        }
        .accessibilityIdentifier("WakeUpNextAlarm")
    }

    private func travelText(_ travelTime: TimeInterval) -> String {
        let duration = Duration.seconds(travelTime)
            .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
        return String(format: String(localized: "Next.TravelTime", table: "WakeUpAlarms"), duration)
    }
}
