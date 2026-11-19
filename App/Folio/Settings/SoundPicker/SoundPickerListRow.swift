import SwiftUI

struct SoundPickerListRow: View {
    let title: String
    let isSelected: Bool
    let isPreviewable: Bool
    let playback: DateInterval?
    let select: () -> Void
    let togglePreview: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: select) {
                HStack(spacing: 12) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
                    Text(title)
                        .foregroundStyle(.primary)
                    Spacer(minLength: 0)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityIdentifier("SoundOption.\(title)")
            if isPreviewable {
                SoundPreviewButton(title: title, playback: playback, action: togglePreview)
            }
        }
    }
}
