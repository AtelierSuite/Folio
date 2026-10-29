import AppIntents
import Planner

struct FolioShortcuts: AppShortcutsProvider {
    static let shortcutTileColor: ShortcutTileColor = .orange

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: WhatsNextIntent(),
            phrases: [
                "What's next in \(.applicationName)",
                "What's my next event in \(.applicationName)",
                "What's coming up in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Shortcut.WhatsNext", table: "AppIntents"),
            systemImageName: "clock"
        )
        AppShortcut(
            intent: TodayAgendaIntent(),
            phrases: [
                "What's on my calendar today in \(.applicationName)",
                "What's on today in \(.applicationName)",
                "Show today in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Shortcut.Today", table: "AppIntents"),
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: JoinNextMeetingIntent(),
            phrases: [
                "Join my next meeting with \(.applicationName)",
                "Join my meeting in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Shortcut.JoinMeeting", table: "AppIntents"),
            systemImageName: "video"
        )
        AppShortcut(
            intent: CreateEventIntent(),
            phrases: [
                "Create an event in \(.applicationName)",
                "Add an event to \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Shortcut.CreateEvent", table: "AppIntents"),
            systemImageName: "calendar.badge.plus"
        )
        AppShortcut(
            intent: CreateReminderIntent(),
            phrases: [
                "Add a reminder in \(.applicationName)",
                "Create a reminder in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Shortcut.CreateReminder", table: "AppIntents"),
            systemImageName: "checklist"
        )
        AppShortcut(
            intent: SetReminderCompletedIntent(),
            phrases: [
                "Complete a reminder in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Shortcut.CompleteReminder", table: "AppIntents"),
            systemImageName: "checkmark.circle"
        )
        AppShortcut(
            intent: CreateNoteIntent(),
            phrases: [
                "Create a note in \(.applicationName)",
                "New \(.applicationName) note"
            ],
            shortTitle: LocalizedStringResource("Shortcut.CreateNote", table: "AppIntents"),
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: AppendToDailyNoteIntent(),
            phrases: [
                "Add to today's note in \(.applicationName)",
                "Add to my daily note in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Shortcut.AppendToDailyNote", table: "AppIntents"),
            systemImageName: "text.append"
        )
        AppShortcut(
            intent: OpenNoteIntent(),
            phrases: [
                "Open a note in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("Shortcut.OpenNote", table: "AppIntents"),
            systemImageName: "note.text"
        )
    }
}
