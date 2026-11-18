import Planner
import SwiftUI

struct AlarmSoundPicker: View {
    let selection: AlarmSound
    let select: (AlarmSound) -> Void
    let accessibilityIdentifier: String
    @State private var player = AlarmSoundPreviewPlayer()

    var body: some View {
        Picker(String(localized: "Row.Sound", table: "AlarmSounds"), selection: Binding(
            get: { selection },
            set: { sound in
                player.play(sound)
                select(sound)
            }
        )) {
            ForEach(AlarmSound.allCases) { sound in
                Text(sound.title).tag(sound)
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier)
        .onDisappear {
            player.stop()
        }
    }
}
