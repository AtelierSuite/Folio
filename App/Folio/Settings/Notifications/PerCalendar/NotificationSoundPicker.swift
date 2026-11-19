import Planner
import SwiftUI

struct NotificationSoundPicker: View {
    @Environment(NotificationScheduler.self) private var scheduler
    let kind: CalendarItemKind
    let calendar: PlannerCalendar?
    let player: NotificationSoundPreviewPlayer

    var body: some View {
        SoundPickerRow(
            title: title,
            options: options,
            selection: Binding(get: { selectedSound }, set: select),
            player: player,
            preview: { sound in player.play(sound ?? defaultSound) }
        )
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    private var title: String {
        calendar == nil
            ? String(localized: "Row.DefaultSound", table: "NotificationSounds")
            : String(localized: "Row.Sound", table: "NotificationSounds")
    }

    private var options: [SoundPickerOption<NotificationSound?>] {
        var options: [SoundPickerOption<NotificationSound?>] = []
        if calendar != nil {
            options.append(SoundPickerOption(
                sound: nil,
                title: NotificationSound.inheritedTitle(defaultSound),
                isPreviewable: defaultSound.isPreviewable
            ))
        }
        options += NotificationSound.choices(for: kind).map { sound in
            SoundPickerOption(sound: sound, title: sound.title, isPreviewable: sound.isPreviewable)
        }
        return options
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
        Task {
            if let calendar {
                await scheduler.setSound(sound, forCalendar: calendar.id)
            } else if let sound {
                await scheduler.setSound(sound, for: kind)
            }
        }
    }
}
