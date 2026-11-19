import SwiftUI

struct SoundPreviewButton: View {
    @ScaledMetric(relativeTo: .title2) private var diameter: CGFloat = 28
    let title: String
    let playback: DateInterval?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.tint.opacity(0.2))
                if let playback {
                    SoundPreviewProgressRing(playback: playback)
                }
                Image(systemName: playback == nil ? "play.fill" : "stop.fill")
                    .font(.system(size: diameter * 0.4, weight: .bold))
                    .foregroundStyle(.tint)
                    .offset(x: playback == nil ? diameter * 0.04 : 0)
                    .contentTransition(.symbolEffect(.replace))
            }
            .frame(width: diameter, height: diameter)
            .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier("SoundPreview.\(title)")
    }

    private var accessibilityLabel: String {
        playback == nil
            ? String(localized: "Preview.Play \(title)", table: "SoundPicker")
            : String(localized: "Preview.Stop \(title)", table: "SoundPicker")
    }
}
