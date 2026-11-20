import SwiftUI

struct OnboardingJourneyProgressLoop<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var progress: Double = 0
    var duration: Double = 3
    var hold: Duration = .seconds(1.5)
    @ViewBuilder let content: (Double) -> Content

    var body: some View {
        content(progress)
            .task(id: reducesMotion) { await play() }
    }

    private func play() async {
        guard !reducesMotion else {
            progress = 1
            return
        }
        try? await Task.sleep(for: .milliseconds(400))
        while !Task.isCancelled {
            withAnimation(.easeInOut(duration: duration)) { progress = 1 }
            try? await Task.sleep(for: .seconds(duration) + hold)
            withAnimation(.easeOut(duration: 0.4)) { progress = 0 }
            try? await Task.sleep(for: .milliseconds(600))
        }
    }
}
