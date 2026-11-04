import Planner
import SwiftUI

struct HourlyHourColumns: View {
    let hours: [Date]
    let hiddenCount: Int

    private var hasNarrowColumns: Bool {
        hours.count > HourlySchedule.defaultHourCount
    }

    private var amPMStyle: Date.FormatStyle.Symbol.Hour.AMPMStyle {
        hasNarrowColumns ? .narrow : .abbreviated
    }

    private func yieldsLabelToHiddenCount(_ hour: Date) -> Bool {
        hasNarrowColumns && hiddenCount > 0 && hour == hours.last
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                VStack(alignment: .leading, spacing: 0) {
                    Text(hour, format: .dateTime.hour(.defaultDigits(amPM: amPMStyle)))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .padding(.leading, 3)
                        .opacity(yieldsLabelToHiddenCount(hour) ? 0 : 1)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(width: 0.5)
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            if hiddenCount > 0 {
                Text(hiddenCount, format: .number.sign(strategy: .always()))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
