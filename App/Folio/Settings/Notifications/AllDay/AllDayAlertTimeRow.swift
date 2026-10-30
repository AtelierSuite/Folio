import Planner
import SwiftUI

struct AllDayAlertTimeRow: View {
    @Environment(NotificationScheduler.self) private var scheduler
    let calendar: PlannerCalendar
    @State private var time: Date = .now

    var body: some View {
        DatePicker(selection: Binding(get: { time }, set: select), displayedComponents: .hourAndMinute) {
            HStack(spacing: 10) {
                Circle()
                    .fill(calendar.color.color)
                    .frame(width: 12, height: 12)
                Text(calendar.title)
            }
        }
        .accessibilityIdentifier("AllDayAlertTime.\(calendar.title)")
        .onAppear {
            time = date(forMinutes: scheduler.allDayAlertMinutes(forCalendar: calendar.id))
        }
    }

    private func select(_ newValue: Date) {
        time = newValue
        let components = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute], from: newValue)
        let minutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        Task { await scheduler.setAllDayAlertMinutes(minutes, forCalendar: calendar.id) }
    }

    private func date(forMinutes minutes: Int) -> Date {
        let startOfDay = Calendar.autoupdatingCurrent.startOfDay(for: .now)
        return Calendar.autoupdatingCurrent.date(byAdding: .minute, value: minutes, to: startOfDay) ?? startOfDay
    }
}
