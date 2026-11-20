import SwiftUI

struct OnboardingProductTourBeat {
    let wait: Duration
    let animation: Animation

    init(_ wait: Duration, _ animation: Animation = .smooth(duration: 0.6)) {
        self.wait = wait
        self.animation = animation
    }
}

struct OnboardingProductTourPlayer<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var phase = 0
    @State private var isRewinding = false
    let beats: [OnboardingProductTourBeat]
    var loops = true
    var hold: Duration = .seconds(2.5)
    @ViewBuilder let content: (Int) -> Content

    var body: some View {
        content(phase)
            .opacity(isRewinding ? 0 : 1)
            .task(id: reducesMotion) { await play() }
    }

    private func play() async {
        guard !reducesMotion else {
            phase = beats.count
            return
        }
        repeat {
            for (index, beat) in beats.enumerated() {
                try? await Task.sleep(for: beat.wait)
                if Task.isCancelled { return }
                withAnimation(beat.animation) { phase = index + 1 }
            }
            guard loops else { return }
            try? await Task.sleep(for: hold)
            if Task.isCancelled { return }
            withAnimation(.easeOut(duration: 0.3)) { isRewinding = true }
            try? await Task.sleep(for: .milliseconds(350))
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { phase = 0 }
            withAnimation(.easeIn(duration: 0.3)) { isRewinding = false }
        } while !Task.isCancelled
    }
}

struct OnboardingProductTourDemo<Scene: View>: View {
    let beats: [OnboardingProductTourBeat]
    var loops = true
    var hold: Duration = .seconds(2.5)
    @ViewBuilder let scene: (Int, OnboardingProductTourCanvas) -> Scene

    var body: some View {
        GeometryReader { proxy in
            OnboardingProductTourPlayer(beats: beats, loops: loops, hold: hold) { phase in
                scene(phase, OnboardingProductTourCanvas(size: proxy.size))
            }
        }
    }
}

struct OnboardingProductTourCanvas {
    let size: CGSize

    var contentTop: CGFloat {
        OnboardingProductTourMetrics.statusBarHeight + OnboardingProductTourMetrics.navBarHeight
    }

    var timelineHeight: CGFloat { size.height - contentTop }

    func timelineMetrics(firstHour: Int) -> OnboardingProductTourTimelineMetrics {
        OnboardingProductTourTimelineMetrics(
            width: size.width,
            hourHeight: timelineHeight / OnboardingProductTourMetrics.visibleHours,
            firstHour: firstHour
        )
    }

    func screenRect(_ rect: CGRect, metrics: OnboardingProductTourTimelineMetrics, topHour: Double) -> CGRect {
        rect.offsetBy(dx: 0, dy: contentTop - metrics.y(for: topHour))
    }
}
