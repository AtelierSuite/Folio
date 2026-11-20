import SwiftUI

struct OnboardingFolioPagesRemindersSketch: View {
    let ink: OnboardingFolioPagesInk
    @Environment(\.colorScheme) private var colorScheme

    private let lineLengths: [CGFloat] = [0.62, 0.48, 0.56]
    private let checkedCount = 2

    var body: some View {
        let palette = OnboardingFolioPagesPalette(colorScheme: colorScheme)
        GeometryReader { proxy in
            let size = proxy.size
            let boxSide = min(size.width * 0.17, size.height * 0.2)
            ForEach(lineLengths.indices, id: \.self) { index in
                let rowY = size.height * (0.17 + CGFloat(index) * 0.33)
                let drawStart = 0.2 + Double(index) * 0.25
                let tickStart = 1.4 + Double(index) * 0.75
                let isChecked = index < checkedCount
                let tick = isChecked ? ink.stroke(tickStart, 0.35) : 0
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .onboardingFolioPagesInked(ink.stroke(drawStart, 0.45), color: palette.ink.opacity(0.75))
                    .frame(width: boxSide, height: boxSide)
                    .position(x: boxSide / 2 + 2, y: rowY)
                OnboardingFolioPagesCheckmark()
                    .onboardingFolioPagesInked(tick, color: .orange, lineWidth: 3.4)
                    .frame(width: boxSide * 1.05, height: boxSide * 1.05)
                    .position(x: boxSide / 2 + 6, y: rowY - 4)
                let lineWidth = size.width * lineLengths[index]
                let lineStart = boxSide + 16
                OnboardingFolioPagesScribble(
                    progress: ink.stroke(drawStart + 0.2, 0.45),
                    color: palette.ink.opacity(isChecked ? 0.55 - 0.3 * ink.stroke(tickStart + 0.3, 0.3) : 0.55),
                    thickness: 6
                )
                .frame(width: lineWidth)
                .position(x: lineStart + lineWidth / 2, y: rowY)
                Rectangle()
                    .fill(palette.ink.opacity(0.8))
                    .frame(width: lineWidth + 8, height: 1.6)
                    .scaleEffect(x: isChecked ? ink.stroke(tickStart + 0.3, 0.35) : 0, y: 1, anchor: .leading)
                    .position(x: lineStart + lineWidth / 2, y: rowY)
            }
        }
    }
}
