import Planner
import SwiftUI

struct NotificationSoundPickerView: View {
    @Environment(NotificationScheduler.self) private var scheduler
    @State private var player = NotificationSoundPreviewPlayer()
    let kind: CalendarItemKind
    let calendar: PlannerCalendar?

    var body: some View {
        Form {
            Section {
                if calendar != nil {
                    NotificationSoundRow(
                        title: NotificationSound.inheritedTitle(defaultSound),
                        identifier: "Default",
                        isSelected: calendarSound == nil
                    ) {
                        select(nil)
                    }
                }
                ForEach(NotificationSound.choices(for: kind)) { sound in
                    NotificationSoundRow(
                        title: sound.title,
                        identifier: sound.rawValue,
                        isSelected: selectedSound == sound
                    ) {
                        select(sound)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(navigationTitle)
        .toolbarTitleDisplayMode(.inline)
        .onDisappear {
            player.stop()
        }
    }

    private var defaultSound: NotificationSound {
        scheduler.sound(for: kind)
    }

    private var calendarSound: NotificationSound? {
        calendar.flatMap { scheduler.sound(forCalendar: $0.id) }
    }

    private var selectedSound: NotificationSound? {
        calendar == nil ? defaultSound : calendarSound
    }

    private var navigationTitle: String {
        calendar?.title ?? String(localized: "Row.Default", table: "NotificationSounds")
    }

    private func select(_ sound: NotificationSound?) {
        player.play(sound ?? defaultSound)
        Task {
            if let calendar {
                await scheduler.setSound(sound, forCalendar: calendar.id)
            } else if let sound {
                await scheduler.setSound(sound, for: kind)
            }
        }
    }
}
