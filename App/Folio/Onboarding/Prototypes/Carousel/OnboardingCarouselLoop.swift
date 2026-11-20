import SwiftUI

struct OnboardingCarouselLoop<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var phase = 0
    let isActive: Bool
    let count: Int
    var interval: Duration = .milliseconds(600)
    var hold: Duration = .seconds(2.5)
    var staticPhase: Int?
    @ViewBuilder let content: (Int) -> Content

    var body: some View {
        content(reducesMotion ? (staticPhase ?? count) : phase)
            .task(id: isActive) { await play() }
    }

    private func play() async {
        guard isActive, !reducesMotion else { return }
        phase = 0
        try? await Task.sleep(for: .milliseconds(450))
        while !Task.isCancelled {
            for _ in 0..<count {
                try? await Task.sleep(for: interval)
                guard !Task.isCancelled else { return }
                withAnimation(.spring(duration: 0.55, bounce: 0.3)) { phase += 1 }
            }
            try? await Task.sleep(for: hold)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.5)) { phase = 0 }
            try? await Task.sleep(for: .milliseconds(650))
        }
    }
}
