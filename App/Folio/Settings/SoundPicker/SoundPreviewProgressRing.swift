import SwiftUI

struct SoundPreviewProgressRing: View {
    private static let lineWidth: CGFloat = 2.5

    let playback: DateInterval

    var body: some View {
        TimelineView(.animation) { context in
            Circle()
                .trim(from: 0, to: progress(at: context.date))
                .stroke(.tint, style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(Self.lineWidth / 2)
        }
        .accessibilityHidden(true)
    }

    private func progress(at date: Date) -> CGFloat {
        guard playback.duration > 0 else { return 1 }
        return min(max(date.timeIntervalSince(playback.start) / playback.duration, 0), 1)
    }
}
