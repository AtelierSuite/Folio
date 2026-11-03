import Planner
import SwiftUI

struct NotificationSoundPicker: View {
    @Environment(NotificationScheduler.self) private var scheduler
    let kind: CalendarItemKind
    let calendar: PlannerCalendar?
    let player: NotificationSoundPreviewPlayer

    var body: some View {
        Picker(selection: Binding(get: { selectedSound }, set: select)) {
            if calendar != nil {
                Text(NotificationSound.inheritedTitle(defaultSound))
                    .tag(NotificationSound?.none)
            }
            ForEach(NotificationSound.choices(for: kind)) { sound in
                Text(sound.title)
                    .tag(NotificationSound?.some(sound))
            }
        } label: {
            if let calendar {
                HStack(spacing: 10) {
                    Circle()
                        .fill(calendar.color.color)
                        .frame(width: 12, height: 12)
                    Text(calendar.title)
                }
            } else {
                Text(String(localized: "Row.Default", table: "NotificationSounds"))
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private var defaultSound: NotificationSound {
        scheduler.sound(for: kind)
    }

    private var selectedSound: NotificationSound? {
        if let calendar {
            scheduler.sound(forCalendar: calendar.id)
        } else {
            defaultSound
        }
    }

    private var accessibilityIdentifier: String {
        if let calendar {
            "NotificationSoundCalendar.\(calendar.title)"
        } else {
            "NotificationSoundDefault.\(kind == .event ? "Events" : "Reminders")"
        }
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
