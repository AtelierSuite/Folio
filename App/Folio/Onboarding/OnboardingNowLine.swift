import SwiftUI

struct OnboardingNowLineSlot: View {
    let geometry: OnboardingTimelineGeometry
    let hour: Double

    static let restingHour = 3.3

    var body: some View {
        Color.clear
            .frame(width: geometry.size.width - geometry.contentMinX + 4, height: OnboardingNowLine.height)
            .anchorPreference(key: OnboardingNowLineKey.self, value: .bounds) { $0 }
            .padding(.leading, geometry.contentMinX - 4)
            .padding(.top, geometry.yPosition(hour) - OnboardingNowLine.height / 2)
            .allowsHitTesting(false)
    }
}

struct OnboardingNowLine: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isDrawn = false
    let frame: CGRect

    static let height: CGFloat = 9

    var body: some View {
        HStack(spacing: 0) {
            Circle().fill(.white).frame(width: Self.height, height: Self.height)
            Rectangle().fill(.white).frame(height: 2)
        }
        .shadow(color: .white.opacity(0.7), radius: 3)
        .frame(width: frame.width, height: frame.height)
        .scaleEffect(x: isDrawn ? 1 : 0, anchor: .leading)
        .offset(x: frame.minX, y: frame.minY)
        .animation(reducesMotion ? nil : .easeOut(duration: 0.8).delay(0.75), value: isDrawn)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { isDrawn = true }
    }
}

nonisolated struct OnboardingNowLineKey: PreferenceKey {
    static let defaultValue: Anchor<CGRect>? = nil

    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

extension View {
    func onboardingNowLineOverlay() -> some View {
        overlayPreferenceValue(OnboardingNowLineKey.self) { anchor in
            GeometryReader { proxy in
                if let anchor {
                    OnboardingNowLine(frame: proxy[anchor])
                }
            }
        }
    }
}
