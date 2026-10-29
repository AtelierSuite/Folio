import Planner
import SwiftUI

struct NotificationStylePicker<Label: View>: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @Environment(PermissionCenter.self) private var permissionCenter
    let selection: NotificationAlertStyle?
    let inheritedStyle: NotificationAlertStyle?
    let onSelect: (NotificationAlertStyle?) async -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Picker(selection: Binding(get: { selection }, set: select)) {
            if let inheritedStyle {
                Text(String(localized: "Style.Inherited \(inheritedStyle.title)", table: "NotificationStyles"))
                    .tag(NotificationAlertStyle?.none)
            }
            ForEach(scheduler.availableStyles) { style in
                SwiftUI.Label(style.title, systemImage: style.systemImage)
                    .tag(Optional(style))
            }
        } label: {
            label()
        }
    }

    private func select(_ style: NotificationAlertStyle?) {
        Task {
            if style == .alarm {
                await permissionCenter.request(.alarms)
            }
            await onSelect(style)
        }
    }
}
