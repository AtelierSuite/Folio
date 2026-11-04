import Planner
import SwiftUI

struct NotificationDetailHeaderView: View {
    let origin: CalendarOrigin?
    let status: String?
    let accentColor: Color

    var body: some View {
        HStack(spacing: 12) {
            if let origin {
                originLabel(origin)
            }
            Spacer(minLength: 0)
            if let status {
                Text(status)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(accentColor)
                    .lineLimit(1)
                    .layoutPriority(1)
                    .accessibilityIdentifier("NotificationDetail.Status")
            }
        }
    }

    private func originLabel(_ origin: CalendarOrigin) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(accentColor)
                .frame(width: 9, height: 9)
            HStack(spacing: 4) {
                if !origin.accountName.isEmpty {
                    Text(origin.accountName)
                        .lineLimit(1)
                    Text(verbatim: "·")
                }
                Text(origin.calendarName)
                    .lineLimit(1)
                    .layoutPriority(1)
            }
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("NotificationDetail.Origin")
    }
}
