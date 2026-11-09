import Planner
import SwiftUI
import WidgetKit

struct UpNextCornerView: View {
    let upNext: WidgetUpNext?
    let date: Date

    var body: some View {
        Image(systemName: upNext?.isOngoing == true ? "hourglass" : "calendar")
            .font(.title3)
            .widgetAccentable()
            .widgetLabel(label)
    }

    private var label: String {
        guard let upNext else { return String(localized: "UpNext.Empty", table: "Complications") }
        return "\(upNext.timing(on: date, calendar: .current).summary) \(upNext.event.title)"
    }
}
