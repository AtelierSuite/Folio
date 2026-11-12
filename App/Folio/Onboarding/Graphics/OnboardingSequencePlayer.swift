import SwiftUI

struct OnboardingSequencePlayer<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var shownCount = 0
    let count: Int
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
        while !Task.isCancelled {
            for _ in 0..<count {
                try? await Task.sleep(for: .milliseconds(500))
                withAnimation(.spring(duration: 0.5, bounce: 0.4)) { shownCount += 1 }
            }
            try? await Task.sleep(for: .seconds(3))
            withAnimation(.easeOut(duration: 0.3)) { shownCount = 0 }
        }
    }
}
