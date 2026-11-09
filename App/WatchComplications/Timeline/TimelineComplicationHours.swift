import SwiftUI
import WidgetKit

struct TimelineComplicationHours: View {
    let hours: [Date]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                Text(hour.formatted(.dateTime.hour(.defaultDigits(amPM: .narrow))))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(.secondary)
                            .frame(width: 1)
                            .offset(x: -3)
                    }
            }
        }
        .padding(.leading, 3)
        .widgetAccentable()
    }
}
