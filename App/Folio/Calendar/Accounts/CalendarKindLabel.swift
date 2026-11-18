import Planner
import SwiftUI

extension CalendarItemKind {
    var accountSymbolName: String {
        switch self {
        case .event: "calendar"
        case .reminder: "list.bullet"
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
    @Environment(CalendarStore.self) private var store
    let calendar: PlannerCalendar
    var subtitle: String?

    var body: some View {
        HStack(spacing: 10) {
            GradientCircleIcon(systemImage: symbolName, color: calendar.color.color)
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

    private var symbolName: String {
        store.isBirthdayCalendar(calendar)
            ? BirthdayStyle.symbolName
            : calendar.kind.accountSymbolName
    }
}
