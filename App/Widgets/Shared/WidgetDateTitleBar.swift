import Planner
import SwiftUI

struct WidgetDateTitleBar: View {
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone
    let date: Date

    var body: some View {
        WidgetTitleBar {
            Text(date, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                .layoutPriority(1)
            Spacer(minLength: 0)
            if let formatter = AlternateCalendarSettings().formatter(timeZone: timeZone, locale: locale) {
                Text(verbatim: formatter.compactDate(for: date))
                    .fontWeight(.regular)
                    .minimumScaleFactor(0.7)
                    .accessibilityLabel(formatter.fullDate(for: date))
            }
        }
    }
}
