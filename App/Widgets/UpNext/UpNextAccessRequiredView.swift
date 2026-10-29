import Planner
import SwiftUI
import WidgetKit

struct UpNextAccessRequiredView: View {
    let family: WidgetFamily

    var body: some View {
        if family.isSystem {
            WidgetAccessRequiredView(kind: .event)
        } else {
            Label(String(localized: "Access.Short", table: "Widgets"), systemImage: "calendar")
                .font(.caption)
        }
    }
}

extension WidgetFamily {
    var isSystem: Bool {
        switch self {
        case .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge: true
        default: false
        }
    }
}
