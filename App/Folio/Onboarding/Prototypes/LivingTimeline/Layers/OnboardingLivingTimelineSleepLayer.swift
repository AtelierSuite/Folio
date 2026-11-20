import SwiftUI

struct OnboardingLivingTimelineSleepLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isFilled = false
    let geometry: OnboardingLivingTimelineGeometry
    let state: OnboardingLivingTimelineLayerState

    private static let bedtimeHour = -0.5
    private static let wakeHour = 1.55

    var body: some View {
        let minY = geometry.yPosition(Self.bedtimeHour)
        let height = geometry.yPosition(Self.wakeHour) - minY
        let width = geometry.contentWidth - 6
        let shape = UnevenRoundedRectangle(bottomLeadingRadius: 10, bottomTrailingRadius: 10)
        shape
            .fill(LinearGradient(
                colors: [.indigo.opacity(0.55), .purple.opacity(0.28)],
                startPoint: .top,
                endPoint: .bottom
            ))
            .overlay(alignment: .leading) {
                HStack(spacing: 8) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .symbolEffect(.breathe, isActive: state == .current && !reducesMotion)
                    Capsule().fill(.white.opacity(0.8)).frame(width: width * 0.28, height: 6)
                }
                .padding(.leading, 12)
                .opacity(isFilled ? 1 : 0)
            }
            .overlay(alignment: .bottom) {
                Capsule()
                    .fill(.yellow)
                    .frame(height: 3)
                    .padding(.horizontal, 6)
                    .opacity(isFilled ? 1 : 0)
            }
            .livingTimelineOutline(state == .current, shape: shape, color: .indigo)
            .frame(width: width, height: height)
            .scaleEffect(y: isFilled ? 1 : 0, anchor: .top)
            .offset(x: geometry.contentMinX + 6, y: minY)
            .onAppear {
                withAnimation(reducesMotion ? nil : .easeInOut(duration: 1.3).delay(0.25)) { isFilled = true }
            }
    }
}
