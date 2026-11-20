import SwiftUI

struct OnboardingMorphingIconAlertBurst: View {
    let beat: Int
    let unit: CGFloat
    @Environment(\.accessibilityReduceMotion) private var reducesMotion

    private static let alertColors: [Color] = [
        Color(red: 1.0, green: 0.72, blue: 0.26), Color(red: 0.95, green: 0.36, blue: 0.15)
    ]

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                ripple(index: index)
            }
            banner
                .keyframeAnimator(initialValue: reducesMotion ? 1.0 : 0.0, trigger: beat) { content, progress in
                    content
                        .scaleEffect(0.4 + 0.6 * progress)
                        .offset(y: -112 * unit * progress)
                        .opacity(max(0, min(1, progress * 2)))
                } keyframes: { _ in
                    LinearKeyframe(0, duration: 0.12)
                    SpringKeyframe(1, duration: 0.6, spring: .bouncy(duration: 0.6, extraBounce: 0.1))
                    LinearKeyframe(1, duration: 2.0)
                    CubicKeyframe(0, duration: 0.45)
                }
        }
    }

    private func ripple(index: Int) -> some View {
        RoundedRectangle(cornerRadius: 38 * unit, style: .continuous)
            .strokeBorder(Self.alertColors[1].opacity(0.7), lineWidth: 2)
            .frame(width: 140 * unit, height: 140 * unit)
            .keyframeAnimator(initialValue: 0.0, trigger: beat) { content, progress in
                content
                    .scaleEffect(1 + progress * 0.8)
                    .opacity(progress == 0 ? 0 : 1 - progress)
            } keyframes: { _ in
                LinearKeyframe(0, duration: 0.05 + Double(index) * 0.22)
                CubicKeyframe(1, duration: 1.3)
            }
    }

    private var banner: some View {
        HStack(spacing: 10 * unit) {
            RoundedRectangle(cornerRadius: 7 * unit, style: .continuous)
                .fill(LinearGradient(colors: Self.alertColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 13 * unit, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 30 * unit, height: 30 * unit)
            VStack(alignment: .leading, spacing: 6 * unit) {
                Capsule().fill(.primary.opacity(0.75)).frame(width: 92 * unit, height: 6 * unit)
                Capsule().fill(.secondary.opacity(0.45)).frame(width: 128 * unit, height: 5 * unit)
            }
            Spacer(minLength: 0)
            Capsule().fill(.secondary.opacity(0.4)).frame(width: 22 * unit, height: 5 * unit)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(12 * unit)
        .frame(width: 236 * unit, height: 58 * unit)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18 * unit, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
    }
}
