struct SoundPickerOption<Sound: Hashable>: Identifiable {
    let sound: Sound
    let title: String
    let isPreviewable: Bool

    var id: Sound { sound }
}
