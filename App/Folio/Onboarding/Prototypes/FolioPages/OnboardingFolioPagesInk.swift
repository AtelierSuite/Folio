import SwiftUI

struct OnboardingFolioPagesInk {
    let time: TimeInterval

    static let finished = OnboardingFolioPagesInk(time: 1_000)

    var isFinished: Bool { time >= Self.finished.time }

    func stroke(_ start: TimeInterval, _ length: TimeInterval = 0.5) -> CGFloat {
        let fraction = min(max((time - start) / length, 0), 1)
        return fraction * fraction * (3 - 2 * fraction)
    }

    func swing(_ start: TimeInterval, _ length: TimeInterval, swings: Double = 4) -> Double {
        let elapsed = time - start
        guard elapsed > 0, elapsed < length else { return 0 }
        let fraction = elapsed / length
        return sin(fraction * .pi * 2 * swings) * (1 - fraction)
    }
}

struct OnboardingFolioPagesInkCanvas<Content: View>: View {
    let animates: Bool
    let delay: TimeInterval
    let duration: TimeInterval
    @ViewBuilder let content: (OnboardingFolioPagesInk) -> Content
    @State private var startDate = Date.now
    @State private var isFinished = false

    var body: some View {
        Group {
            if animates && !isFinished {
                TimelineView(.animation) { timeline in
                    content(OnboardingFolioPagesInk(time: timeline.date.timeIntervalSince(startDate) - delay))
                }
            } else {
                content(.finished)
            }
        }
        .onAppear { startDate = .now }
        .task {
            guard animates else { return }
            try? await Task.sleep(for: .seconds(delay + duration))
            isFinished = true
        }
    }
}

extension Shape {
    func onboardingFolioPagesInked(
        _ progress: CGFloat,
        color: Color,
        lineWidth: CGFloat = 2.2,
        dash: [CGFloat] = []
    ) -> some View {
        trim(from: 0, to: progress)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round, dash: dash))
    }
}

extension View {
    func onboardingFolioPagesPlaced(
        in size: CGSize,
        horizontal: CGFloat,
        vertical: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        frame(width: size.width * width, height: size.height * height)
            .position(x: size.width * horizontal, y: size.height * vertical)
    }

    func onboardingFolioPagesPlaced(
        in size: CGSize,
        horizontal: CGFloat,
        vertical: CGFloat,
        side: CGFloat
    ) -> some View {
        let length = min(size.width, size.height) * side
        return frame(width: length, height: length)
            .position(x: size.width * horizontal, y: size.height * vertical)
    }
}

struct OnboardingFolioPagesScribble: View {
    let progress: CGFloat
    let color: Color
    var thickness: CGFloat = 5

    var body: some View {
        Capsule()
            .fill(color)
            .frame(height: thickness)
            .scaleEffect(x: progress, y: 1, anchor: .leading)
            .opacity(progress > 0 ? 1 : 0)
    }
}
