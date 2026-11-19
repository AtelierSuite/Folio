import SwiftUI

struct SoundPickerListRow: View {
    let title: String
    let isSelected: Bool
    let isPreviewable: Bool
    let isPlaying: Bool
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
                Button(action: togglePreview) {
                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.tint)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(previewLabel)
                .accessibilityIdentifier("SoundPreview.\(title)")
            }
        }
    }

    private var previewLabel: String {
        isPlaying
            ? String(localized: "Preview.Stop \(title)", table: "SoundPicker")
            : String(localized: "Preview.Play \(title)", table: "SoundPicker")
    }
}
