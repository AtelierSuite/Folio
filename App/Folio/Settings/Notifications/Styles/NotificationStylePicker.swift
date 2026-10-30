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
                Text(inheritedTitle(inheritedStyle))
                    .tag(NotificationAlertStyle?.none)
            }
            ForEach(scheduler.availableStyles) { style in
                SwiftUI.Label(style.title, systemImage: style.systemImage)
                    .tag(Optional(style))
            }
        } label: {
            label()
        } currentValueLabel: {
            Text(currentTitle)
        }
    }

    private var currentTitle: String {
        if let selection {
            selection.title
        } else if let inheritedStyle {
            inheritedTitle(inheritedStyle)
        } else {
            ""
        }
    }

    private func inheritedTitle(_ style: NotificationAlertStyle) -> String {
        String(localized: "Style.Inherited \(style.title)", table: "NotificationStyles")
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
