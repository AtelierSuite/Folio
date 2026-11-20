import SwiftUI

struct OnboardingMorphingIconStage: View {
    let step: OnboardingStep
    let face: OnboardingMorphingIconFace
    let features: [OnboardingFeature]
    let highlightedFeature: OnboardingFeature?
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var symbol: String
    @State private var colors: [Color]
    @State private var flipCount = 0
    @State private var shakeCount = 0
    @State private var bounceCount = 0
    @State private var beat = 0

    init(
        step: OnboardingStep,
        face: OnboardingMorphingIconFace,
        features: [OnboardingFeature],
        highlightedFeature: OnboardingFeature?
    ) {
        self.step = step
        self.face = face
        self.features = features
        self.highlightedFeature = highlightedFeature
        _symbol = State(initialValue: face.symbol)
        _colors = State(initialValue: face.colors)
    }

    var body: some View {
        ZStack {
            OnboardingMorphingIconBackLayer(
                step: step, beat: beat, unit: unit, features: features, highlightedFeature: highlightedFeature
            )
            OnboardingMorphingIconTile(
                symbol: symbol,
                colors: colors,
                size: Metrics.tileSize,
                flipCount: flipCount,
                shakeCount: shakeCount,
                bounceCount: bounceCount
            )
            OnboardingMorphingIconFrontLayer(step: step, beat: beat, unit: unit)
        }
        .frame(height: Metrics.stageHeight)
        .frame(maxWidth: .infinity)
        .animation(.spring(duration: 0.6, bounce: 0.3), value: step)
        .task(id: face) { await morph(to: face) }
        .task(id: step) { await runBeats() }
        .accessibilityHidden(true)
    }

    private var unit: CGFloat { Metrics.tileSize / 140 }

    private func morph(to face: OnboardingMorphingIconFace) async {
        guard face.symbol != symbol || face.colors != colors else { return }
        guard !reducesMotion else {
            symbol = face.symbol
            colors = face.colors
            return
        }
        flipCount += 1
        withAnimation(.smooth(duration: 0.7)) { colors = face.colors }
        guard (try? await Task.sleep(for: .milliseconds(200))) != nil else { return }
        symbol = face.symbol
    }

    private func runBeats() async {
        beat = 0
        guard !reducesMotion, let rhythm = OnboardingMorphingIconRhythm(step: step) else { return }
        var delay = rhythm.firstDelay
        while (try? await Task.sleep(for: delay)) != nil {
            beat += 1
            delay = rhythm.interval
            switch step {
            case .setup(.alerts): shakeCount += 1
            case .setup(.reminders) where rhythm.checksCircle(atBeat: beat): bounceCount += 1
            default: break
            }
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let tileSize: CGFloat = 116
        #else
        static let tileSize: CGFloat = 140
        #endif
        static let stageHeight: CGFloat = tileSize / 140 * 300
    }
}
