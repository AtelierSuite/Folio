import SwiftUI

struct OnboardingFinalNowLine: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isDrawn = false
    let geometry: OnboardingFinalTimelineGeometry
    let hour: Double

    static let restingHour = 3.3

    var body: some View {
        HStack(spacing: 0) {
            Circle().fill(.white).frame(width: 9, height: 9)
            Rectangle().fill(.white).frame(height: 2)
        }
        .shadow(color: .white.opacity(0.7), radius: 3)
        .frame(width: geometry.size.width - geometry.contentMinX + 4)
        .scaleEffect(x: isDrawn ? 1 : 0, anchor: .leading)
        .offset(x: geometry.contentMinX - 4, y: geometry.yPosition(hour) - 4.5)
        .animation(reducesMotion ? nil : .easeOut(duration: 0.8).delay(0.75), value: isDrawn)
        .allowsHitTesting(false)
        .onAppear { isDrawn = true }
    }
}
