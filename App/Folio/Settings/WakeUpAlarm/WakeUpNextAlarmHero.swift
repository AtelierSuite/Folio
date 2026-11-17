import Planner
import SwiftUI

struct WakeUpNextAlarmHero: View {
    @Environment(WakeUpAlarmCenter.self) private var wakeUpAlarms

    var body: some View {
        if wakeUpAlarms.isSupported && wakeUpAlarms.isEnabled {
            Section {
                content
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("WakeUpNextAlarm")
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "alarm.fill")
                Text(String(localized: "Next", table: "WakeUpAlarms"))
            }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            if let alarm = wakeUpAlarms.upcomingAlarms.first {
                Text(alarm.fireDate.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 56, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(alarm.fireDate.formatted(.dateTime.weekday(.wide).month().day()))
                    .font(.headline)
                Text(alarm.event.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                if let travelTime = alarm.travelTime {
                    Text(travelText(travelTime))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(String(localized: "Next.None", table: "WakeUpAlarms"))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
    }

    private func travelText(_ travelTime: TimeInterval) -> String {
        let duration = Duration.seconds(travelTime)
            .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
        return String(format: String(localized: "Next.TravelTime", table: "WakeUpAlarms"), duration)
    }
}
