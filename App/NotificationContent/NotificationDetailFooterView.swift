import Planner
import SwiftUI

struct NotificationDetailFooterView: View {
    let place: NotificationDetailRow?
    let meeting: NotificationDetailRow?

    var body: some View {
        if place != nil || meeting != nil {
            HStack(alignment: .top, spacing: 12) {
                if let place {
                    NotificationDetailRowView(row: place)
                }
                Spacer(minLength: 0)
                if let meeting {
                    NotificationDetailRowView(row: meeting)
                        .fixedSize()
                }
            }
            .foregroundStyle(.secondary)
        }
    }
}
