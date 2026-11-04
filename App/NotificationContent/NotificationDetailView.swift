import Planner
import SwiftUI

struct NotificationDetailView: View {
    let detail: NotificationDetail

    var body: some View {
        VStack(spacing: 12) {
            if detail.origin != nil || detail.hasStatus {
                // The schedule's date is rounded down to the minute, so it only triggers the refresh.
                TimelineView(.everyMinute) { _ in
                    NotificationDetailHeaderView(
                        origin: detail.origin,
                        status: detail.status(at: .now),
                        accentColor: accentColor
                    )
                }
                Divider()
            }
            VStack(spacing: 6) {
                Text(detail.title)
                    .font(.title3.bold())
                    .lineLimit(3)
                    .accessibilityIdentifier("NotificationDetail.Title")
                if let time = detail.row(.time) {
                    Text(time.text)
                        .font(.subheadline)
                        .accessibilityIdentifier("NotificationDetail.Time")
                }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            NotificationDetailFooterView(place: detail.row(.place), meeting: detail.row(.meeting))
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
    }

    private var accentColor: Color {
        detail.color.map { Color(red: $0.red, green: $0.green, blue: $0.blue) } ?? .accentColor
    }
}
