import Planner
import SwiftUI

struct NotificationStyleGallery: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(PermissionCenter.self) private var permissionCenter
    let selection: NotificationAlertStyle
    let onSelect: (NotificationAlertStyle) async -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(scheduler.availableStyles) { style in
                NotificationStyleOption(style: style, isSelected: style == selection) {
                    select(style)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }

    private func select(_ style: NotificationAlertStyle) {
        Task {
            if style == .alarm {
                await permissionCenter.request(.alarms)
            }
            await onSelect(style)
        }
    }
}
