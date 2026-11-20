import SwiftUI

struct OnboardingFolioPagesCalendarSketch: View {
    let ink: OnboardingFolioPagesInk
    @Environment(\.colorScheme) private var colorScheme

    private struct Block {
        let column: Int
        let row: CGFloat
        let length: CGFloat
        let color: Color
    }

    private static let columns = 5
    private static let rows = 5
    private static let gridTop: CGFloat = 0.16

    private let blocks = [
        Block(column: 0, row: 0.2, length: 1.4, color: .pink),
        Block(column: 2, row: 1.1, length: 2.2, color: .orange),
        Block(column: 3, row: 0.1, length: 1, color: .teal),
        Block(column: 1, row: 2.6, length: 1.6, color: .indigo),
        Block(column: 4, row: 2.2, length: 2.4, color: .red)
    ]

    var body: some View {
        let palette = OnboardingFolioPagesPalette(colorScheme: colorScheme)
        GeometryReader { proxy in
            let size = proxy.size
            let gridHeight = size.height * (1 - Self.gridTop)
            let cellWidth = size.width / CGFloat(Self.columns)
            let cellHeight = gridHeight / CGFloat(Self.rows)
            ForEach(0..<Self.columns, id: \.self) { column in
                OnboardingFolioPagesScribble(
                    progress: ink.stroke(0.1 + Double(column) * 0.08, 0.3),
                    color: palette.ink.opacity(0.45),
                    thickness: 4
                )
                .frame(width: cellWidth * 0.55)
                .position(x: cellWidth * (CGFloat(column) + 0.5), y: size.height * Self.gridTop * 0.45)
            }
            OnboardingFolioPagesGridLines(columns: Self.columns, rows: Self.rows)
                .onboardingFolioPagesInked(ink.stroke(0.3, 1.3), color: palette.ink.opacity(0.4), lineWidth: 1.2)
                .frame(width: size.width, height: gridHeight)
                .offset(y: size.height * Self.gridTop)
            ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                eventBlock(block, start: 1.5 + Double(index) * 0.32)
                    .frame(width: cellWidth - 6, height: cellHeight * block.length - 4)
                    .position(
                        x: cellWidth * (CGFloat(block.column) + 0.5),
                        y: size.height * Self.gridTop + cellHeight * (block.row + block.length / 2)
                    )
            }
        }
    }

    private func eventBlock(_ block: Block, start: TimeInterval) -> some View {
        let shape = RoundedRectangle(cornerRadius: 4, style: .continuous)
        let fill = ink.stroke(start + 0.25, 0.4)
        return ZStack(alignment: .topLeading) {
            shape
                .fill(block.color.opacity(0.75))
                .scaleEffect(x: 1, y: fill, anchor: .top)
            shape.onboardingFolioPagesInked(ink.stroke(start, 0.35), color: block.color, lineWidth: 1.6)
            Capsule()
                .fill(.white.opacity(0.85))
                .frame(width: 18, height: 3)
                .padding(5)
                .opacity(fill)
        }
    }
}
