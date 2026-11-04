import Planner
import SwiftUI

struct NotificationDetailFooterView: View {
    let leading: NotificationDetailRow?
    let trailing: NotificationDetailRow?

    var body: some View {
        if leading != nil || trailing != nil {
            HStack(alignment: .top, spacing: 12) {
                if let leading {
                    NotificationDetailRowView(row: leading)
                }
                Spacer(minLength: 0)
                if let trailing {
                    NotificationDetailRowView(row: trailing)
                        .fixedSize()
                }
            }
            .foregroundStyle(.secondary)
        }
    }
}
