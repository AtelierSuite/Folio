import SwiftUI

struct OnboardingFinalTimelineGrid: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isDrawn = false
    let geometry: OnboardingFinalTimelineGeometry
    let nowHour: Double

    static let restingNowHour = 3.3

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<OnboardingFinalTimelineGeometry.rowCount, id: \.self) { hour in
                hourRow(hour)
            }
            nowLine
        }
        .onAppear { isDrawn = true }
    }

    private var nowLine: some View {
        HStack(spacing: 0) {
            Circle().fill(.white).frame(width: 9, height: 9)
            Rectangle().fill(.white).frame(height: 2)
        }
        .shadow(color: .white.opacity(0.7), radius: 3)
        .frame(width: geometry.size.width - geometry.contentMinX + 4)
        .scaleEffect(x: isDrawn ? 1 : 0, anchor: .leading)
        .offset(x: geometry.contentMinX - 4, y: geometry.yPosition(nowHour) - 4.5)
        .animation(reducesMotion ? nil : .easeOut(duration: 0.8).delay(0.75), value: isDrawn)
    }

    private func hourRow(_ hour: Int) -> some View {
        let yPosition = geometry.yPosition(Double(hour))
        return ZStack(alignment: .topLeading) {
            Capsule()
                .fill(.white.opacity(0.45))
                .frame(width: 16, height: 5)
                .offset(x: 12, y: yPosition - 2.5)
                .opacity(isDrawn ? 1 : 0)
            Rectangle()
                .fill(.white.opacity(0.22))
                .frame(width: geometry.size.width - geometry.contentMinX, height: 1)
                .scaleEffect(x: isDrawn ? 1 : 0, anchor: .leading)
                .offset(x: geometry.contentMinX, y: yPosition)
        }
        .animation(
            reducesMotion ? nil : .spring(duration: 0.7, bounce: 0.1).delay(0.15 + Double(hour) * 0.06),
            value: isDrawn
        )
    }
}
