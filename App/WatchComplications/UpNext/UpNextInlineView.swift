import Planner
import SwiftUI
import WidgetKit

struct UpNextInlineView: View {
    let upNext: WidgetUpNext?
    let date: Date

    var body: some View {
        if let upNext {
            let line = "\(upNext.timing(on: date, calendar: .current).summary) \(upNext.event.title)"
            ViewThatFits {
                Label(line, systemImage: "calendar")
                Text(verbatim: line)
            }
            .privacySensitive()
        } else {
            Label(String(localized: "UpNext.Empty", table: "Complications"), systemImage: "calendar")
        }
    }
}
