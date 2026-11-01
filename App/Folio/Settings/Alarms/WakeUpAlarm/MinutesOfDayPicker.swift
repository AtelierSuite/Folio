import SwiftUI

struct MinutesOfDayPicker: View {
    let title: String
    let minutes: Int
    let select: (Int) -> Void

    var body: some View {
        DatePicker(
            title,
            selection: Binding(get: { date(forMinutes: minutes) }, set: pick),
            displayedComponents: .hourAndMinute
        )
    }

    private func pick(_ date: Date) {
        let components = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute], from: date)
        select((components.hour ?? 0) * 60 + (components.minute ?? 0))
    }

    private func date(forMinutes minutes: Int) -> Date {
        let startOfDay = Calendar.autoupdatingCurrent.startOfDay(for: .now)
        return Calendar.autoupdatingCurrent.date(byAdding: .minute, value: minutes, to: startOfDay) ?? startOfDay
    }
}
