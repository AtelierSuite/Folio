import Planner
import SwiftUI

struct NotificationSoundsView: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @State private var player = NotificationSoundPreviewPlayer()

    var body: some View {
        Form {
            section(for: .event, isIncluded: scheduler.includesEvents) {
                Text(String(localized: "Section.Events", table: "NotificationSounds"))
            }
            section(for: .reminder, isIncluded: scheduler.includesReminders) {
                Text(String(localized: "Section.Reminders", table: "NotificationSounds"))
            }
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "Title", table: "NotificationSounds"))
        .toolbarTitleDisplayMode(.inline)
        .onDisappear {
            player.stop()
        }
    }

    private func section(
        for kind: CalendarItemKind, isIncluded: Bool, @ViewBuilder header: () -> some View
    ) -> some View {
        Section {
            ForEach(NotificationSound.choices(for: kind)) { sound in
                NotificationSoundRow(sound: sound, isSelected: scheduler.sound(for: kind) == sound) {
                    player.play(sound)
                    Task { await scheduler.setSound(sound, for: kind) }
                }
            }
        } header: {
            header()
        }
        .disabled(!isIncluded)
    }
}
