import Planner
import SwiftUI
import WidgetKit

struct UpNextCircularView: View {
    let timing: WidgetUpNextTiming?

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                header
                    .font(.caption2)
                    .widgetAccentable()
                Text(verbatim: timing?.clock ?? "–")
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(4)
        }
    }

    @ViewBuilder
    private var header: some View {
        if timing?.isOngoing == true {
            Image(systemName: "hourglass")
        } else if let weekday = timing?.weekday {
            Text(verbatim: weekday)
        } else {
            Image(systemName: "calendar")
        }
    }
}
