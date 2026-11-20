import SwiftUI

enum OnboardingFinalBadgeState {
    case upcoming
    case current
    case completed
    case declined
}

struct OnboardingFinalBadge: View {
    let step: OnboardingSetupStep
    let state: OnboardingFinalBadgeState

    var body: some View {
        let diameter = state == .current ? Metrics.currentDiameter : Metrics.diameter
        ZStack {
            symbol(diameter: diameter)
                .foregroundStyle(symbolStyle)
                .frame(width: diameter, height: diameter)
                .glassEffect(glass, in: .circle)
        }
        .frame(width: Metrics.currentDiameter + 16, height: Metrics.currentDiameter + 16)
        .animation(.spring(duration: 0.55, bounce: 0.45), value: state)
    }

    @ViewBuilder
    private func symbol(diameter: CGFloat) -> some View {
        if state == .completed || state == .declined {
            Image(systemName: state == .completed ? "checkmark" : "xmark")
                .font(.system(size: diameter * 0.4, weight: .heavy))
                .transition(.scale(scale: 0.1).combined(with: .opacity))
        } else {
            Image(systemName: OnboardingFinalPalette.symbol(for: step))
                .font(.system(size: diameter * 0.42, weight: .semibold))
                .transition(.scale(scale: 0.6).combined(with: .opacity))
        }
    }

    private var symbolStyle: Color {
        switch state {
        case .upcoming: .white.opacity(0.8)
        case .current: OnboardingFinalPalette.tint(for: step)
        case .completed: .white
        case .declined: .white.opacity(0.75)
        }
    }

    private var glass: Glass {
        switch state {
        case .upcoming: .regular
        case .current: .regular.tint(.white)
        case .completed: .regular.tint(OnboardingFinalPalette.tint(for: step).opacity(0.6))
        case .declined: .regular
        }
    }

    private enum Metrics {
        #if os(macOS)
        static let diameter: CGFloat = 28
        static let currentDiameter: CGFloat = 38
        #else
        static let diameter: CGFloat = 32
        static let currentDiameter: CGFloat = 44
        #endif
    }
}
