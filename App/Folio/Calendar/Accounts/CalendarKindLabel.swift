import Planner
import SwiftUI

extension CalendarItemKind {
    var accountSymbolName: String {
        switch self {
        case .event: "calendar"
        case .reminder: "checklist"
        }
    }

    var accountKindName: String {
        switch self {
        case .event: String(localized: "Kind.Calendar", table: "CalendarAccounts")
        case .reminder: String(localized: "Kind.List", table: "CalendarAccounts")
        }
    }
}

struct CalendarKindLabel: View {
    let calendar: PlannerCalendar
    var subtitle: String?
    var iconSize: CGFloat = 17

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: calendar.kind.accountSymbolName)
                .font(.system(size: iconSize))
                .foregroundStyle(calendar.color.color)
                .frame(width: iconSize + 4)
                .accessibilityLabel(calendar.kind.accountKindName)
            VStack(alignment: .leading, spacing: 2) {
                Text(calendar.title)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
