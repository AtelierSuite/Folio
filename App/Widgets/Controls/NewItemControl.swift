import AppIntents
import Planner
import SwiftUI
import WidgetKit

struct NewEventControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        NewItemControlConfiguration.make(
            kind: "NewEventControl",
            action: NewEventIntent(),
            title: "Control.NewEvent",
            systemImage: "calendar.badge.plus"
        )
    }
}

struct NewReminderControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        NewItemControlConfiguration.make(
            kind: "NewReminderControl",
            action: NewReminderIntent(),
            title: "Control.NewReminder",
            systemImage: "checklist"
        )
    }
}

struct NewNoteControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        NewItemControlConfiguration.make(
            kind: "NewNoteControl",
            action: NewNoteIntent(),
            title: "Control.NewNote",
            systemImage: "square.and.pencil"
        )
    }
}

enum NewItemControlConfiguration {
    static func make<Action: AppIntent>(
        kind: String,
        action: Action,
        title: String.LocalizationValue,
        systemImage: String
    ) -> some ControlWidgetConfiguration {
        let label = String(localized: title, table: "Widgets")
        return StaticControlConfiguration(kind: kind) {
            ControlWidgetButton(action: action) {
                Label(label, systemImage: systemImage)
            }
        }
        .displayName(LocalizedStringResource(title, table: "Widgets"))
    }
}
