import SwiftUI

struct SoundPickerList<Sound: Hashable>: View {
    let options: [SoundPickerOption<Sound>]
    @Binding var selection: Sound
    let player: any SoundPreviewing
    let preview: (Sound) -> Void
    @State private var previewedSound: Sound?

    var body: some View {
        Form {
            Section {
                ForEach(options) { option in
                    SoundPickerListRow(
                        title: option.title,
                        isSelected: option.sound == selection,
                        isPreviewable: option.isPreviewable,
                        isPlaying: player.isPlaying && previewedSound == option.sound,
                        select: { selection = option.sound },
                        togglePreview: { togglePreview(of: option.sound) }
                    )
                }
            }
        }
        .formStyle(.grouped)
        .onDisappear {
            player.stop()
        }
    }

    private func togglePreview(of sound: Sound) {
        if player.isPlaying && previewedSound == sound {
            player.stop()
        } else {
            previewedSound = sound
            preview(sound)
        }
    }
}
