import Planner
import SwiftUI
import WidgetKit

struct NewEventControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        NewItemControlConfiguration.make(kind: "NewEventControl", item: .event, title: "Control.NewEvent", systemImage: "calendar.badge.plus")
    }
}

struct NewReminderControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        NewItemControlConfiguration.make(kind: "NewReminderControl", item: .reminder, title: "Control.NewReminder", systemImage: "checklist")
    }
}

struct NewNoteControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        NewItemControlConfiguration.make(kind: "NewNoteControl", item: .note, title: "Control.NewNote", systemImage: "square.and.pencil")
    }
}

enum NewItemControlConfiguration {
    static func make(
        kind: String,
        item: NewItemKind,
        title: String.LocalizationValue,
        systemImage: String
    ) -> some ControlWidgetConfiguration {
        let label = String(localized: title, table: "Widgets")
        return StaticControlConfiguration(kind: kind) {
            ControlWidgetButton(action: OpenComposerIntent(kind: item)) {
                Label(label, systemImage: systemImage)
            }
        }
        .displayName(LocalizedStringResource(title, table: "Widgets"))
    }
}
