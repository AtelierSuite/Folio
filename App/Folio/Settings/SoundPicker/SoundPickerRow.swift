import SwiftUI

struct SoundPickerRow<Sound: Hashable>: View {
    let title: String
    let options: [SoundPickerOption<Sound>]
    @Binding var selection: Sound
    let player: any SoundPreviewing
    let preview: (Sound) -> Void
    @State private var isPresented = false

    var body: some View {
        #if os(macOS)
        Button {
            isPresented = true
        } label: {
            label
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isPresented, onDismiss: player.stop) {
            SettingsSheet(title: title) {
                list
            }
        }
        #else
        NavigationLink {
            list
                .navigationTitle(title)
                .toolbarTitleDisplayMode(.inline)
        } label: {
            label
        }
        #endif
    }

    private var list: some View {
        SoundPickerList(options: options, selection: $selection, player: player, preview: preview)
    }

    private var label: some View {
        HStack {
            Text(title)
            Spacer()
            Text(selectedTitle)
                .foregroundStyle(.secondary)
            #if os(macOS)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
            #endif
        }
    }

    private var selectedTitle: String {
        options.first { $0.sound == selection }?.title ?? ""
    }
}
