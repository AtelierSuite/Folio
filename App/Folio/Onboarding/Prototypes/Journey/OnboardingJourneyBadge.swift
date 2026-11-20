import SwiftUI

enum OnboardingJourneyMilestoneState {
    case preview
    case upcoming
    case current
    case completed
}

struct OnboardingJourneyBadge: View {
    let step: OnboardingSetupStep
    let state: OnboardingJourneyMilestoneState

    var body: some View {
        ZStack {
            background
            if state == .completed {
                OnboardingJourneyCheckmark()
            } else {
                Image(systemName: OnboardingJourneyPalette.symbol(for: step))
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.semibold)
                    .foregroundStyle(symbolStyle)
                    .scaleEffect(0.48)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private var background: some View {
        switch state {
        case .preview:
            Circle()
                .fill(.background)
                .overlay { Circle().fill(tint.opacity(0.14)) }
                .overlay { Circle().strokeBorder(tint.opacity(0.5), lineWidth: 2) }
                .shadow(color: tint.opacity(0.25), radius: 6, y: 3)
        case .upcoming:
            Circle()
                .fill(.background)
                .overlay {
                    Circle().strokeBorder(tint.opacity(0.55), style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                }
        case .current, .completed:
            Circle()
                .fill(OnboardingJourneyPalette.gradient(for: step))
                .overlay { Circle().strokeBorder(.white.opacity(0.35), lineWidth: 1.5) }
                .shadow(color: tint.opacity(0.4), radius: 8, y: 4)
        }
    }

    private var symbolStyle: AnyShapeStyle {
        switch state {
        case .preview: AnyShapeStyle(OnboardingJourneyPalette.gradient(for: step))
        case .upcoming: AnyShapeStyle(tint.opacity(0.7))
        case .current, .completed: AnyShapeStyle(.white)
        }
    }

    private var tint: Color {
        OnboardingJourneyPalette.tint(for: step)
    }
}

private struct OnboardingJourneyCheckmark: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isPopped = false

    var body: some View {
        Image(systemName: "checkmark")
            .resizable()
            .scaledToFit()
            .fontWeight(.heavy)
            .foregroundStyle(.white)
            .scaleEffect(isPopped ? 0.44 : 0.05)
            .opacity(isPopped ? 1 : 0)
            .onAppear {
                guard !reducesMotion else {
                    isPopped = true
                    return
                }
                withAnimation(.spring(duration: 0.5, bounce: 0.6).delay(0.45)) { isPopped = true }
            }
    }
}
