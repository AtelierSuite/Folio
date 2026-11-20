import SwiftUI

struct OnboardingSequencePlayer<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var shownCount = 0
    let count: Int
    var interval: Duration = .milliseconds(500)
    var hold: Duration = .seconds(3)
    @ViewBuilder let content: (Int) -> Content

    var body: some View {
        content(shownCount)
            .task(id: reducesMotion) { await play() }
    }

    private func play() async {
        guard !reducesMotion else {
            shownCount = count
            return
        }
        try? await Task.sleep(for: .milliseconds(300))
        while !Task.isCancelled {
            for _ in 0..<count {
                try? await Task.sleep(for: interval)
                withAnimation(.spring(duration: 0.5, bounce: 0.35)) { shownCount += 1 }
            }
            try? await Task.sleep(for: hold)
            withAnimation(.easeOut(duration: 0.35)) { shownCount = 0 }
            try? await Task.sleep(for: .milliseconds(400))
        }
    }
}
