import SwiftUI

struct WatchHourLabels: View {
    let firstDay: Date
    let hours: Range<Int>

    var body: some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                Text(label(for: hour))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: WatchHourGrid.labelWidth, height: WatchHourGrid.hourHeight, alignment: .topTrailing)
                    .offset(y: -5)
                    .id(WatchHourGrid.hourID(hour))
            }
        }
    }

    private func label(for hour: Int) -> String {
        guard hour > 0,
              let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: firstDay) else {
            return ""
        }
        return date.formatted(.dateTime.hour(.defaultDigits(amPM: .narrow)))
    }
}
