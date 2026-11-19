import Planner
import SwiftUI

struct AlarmSoundPicker: View {
    let selection: AlarmSound
    let select: (AlarmSound) -> Void
    let accessibilityIdentifier: String
    @State private var player = AlarmSoundPreviewPlayer()

    var body: some View {
        SoundPickerRow(
            title: String(localized: "Row.Sound", table: "AlarmSounds"),
            options: AlarmSound.allCases.map { sound in
                SoundPickerOption(sound: sound, title: sound.title, isPreviewable: sound.isPreviewable)
            },
            selection: Binding(get: { selection }, set: { sound in select(sound) }),
            player: player,
            preview: player.play
        )
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
