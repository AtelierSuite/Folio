import Planner
import SwiftUI

struct EventAlertsSection: View {
    @Binding var alerts: [EventAlert]
    let isAllDay: Bool

    private var presets: [EventAlert] {
        EventAlert.presets(isAllDay: isAllDay)
    }

    var body: some View {
        Section {
            ForEach(Array(alerts.enumerated()), id: \.offset) { index, alert in
                Picker(String(localized: "Field.Alert", table: "EventEditor"), selection: selection(at: index)) {
                    Text(String(localized: "Alert.None", table: "EventEditor"))
                        .tag(EventAlert?.none)
                    ForEach(options(including: alert)) { option in
                        Text(option.title(isAllDay: isAllDay))
                            .tag(Optional(option))
                    }
                }
            }
            Button(String(localized: "Field.AddAlert", table: "EventEditor"), systemImage: "bell.badge") {
                let unused = presets.first { !alerts.contains($0) } ?? EventAlert.defaultAlert(isAllDay: isAllDay)
                alerts.append(alerts.isEmpty ? EventAlert.defaultAlert(isAllDay: isAllDay) : unused)
            }
        }
    }

    private func options(including alert: EventAlert) -> [EventAlert] {
        presets.contains(alert) ? presets : [alert] + presets
    }

    private func selection(at index: Int) -> Binding<EventAlert?> {
        Binding(
            get: { alerts.indices.contains(index) ? alerts[index] : nil },
            set: { newValue in
                guard alerts.indices.contains(index) else { return }
                if let newValue {
                    alerts[index] = newValue
                } else {
                    alerts.remove(at: index)
                }
            }
        )
    }
}
