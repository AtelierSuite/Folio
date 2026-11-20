import SwiftUI

struct OnboardingLivingTimelineGrid: View {
    @Environment(\.accessibilityReduceMotion) private var reducesMotion
    @State private var isDrawn = false
    let geometry: OnboardingLivingTimelineGeometry

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<OnboardingLivingTimelineGeometry.rowCount, id: \.self) { hour in
                hourRow(hour)
            }
            nowLine
        }
        .onAppear { isDrawn = true }
    }

    private var nowLine: some View {
        let yPosition = geometry.yPosition(Self.nowHour)
        let width = geometry.size.width - geometry.contentMinX
        return HStack(spacing: 0) {
            Circle().fill(.red).frame(width: 9, height: 9)
            Rectangle().fill(.red).frame(height: 2)
        }
        .frame(width: width + 4)
        .scaleEffect(x: isDrawn ? 1 : 0, anchor: .leading)
        .offset(x: geometry.contentMinX - 4, y: yPosition - 4.5)
        .animation(reducesMotion ? nil : .easeOut(duration: 0.8).delay(0.75), value: isDrawn)
    }

    private static let nowHour = 3.3

    private func hourRow(_ hour: Int) -> some View {
        let yPosition = geometry.yPosition(Double(hour))
        let animation: Animation? = reducesMotion ? nil
            : .spring(duration: 0.7, bounce: 0.1).delay(0.15 + Double(hour) * 0.06)
        return ZStack(alignment: .topLeading) {
            Capsule()
                .fill(.tertiary)
                .frame(width: 18, height: 5)
                .offset(x: 12, y: yPosition - 2.5)
                .opacity(isDrawn ? 1 : 0)
            Rectangle()
                .fill(.quaternary)
                .frame(width: geometry.size.width - geometry.contentMinX, height: 1)
                .scaleEffect(x: isDrawn ? 1 : 0, anchor: .leading)
                .offset(x: geometry.contentMinX, y: yPosition)
        }
        .animation(animation, value: isDrawn)
    }
}
