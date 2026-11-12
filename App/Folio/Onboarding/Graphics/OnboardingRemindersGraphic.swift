import SwiftUI

struct OnboardingRemindersGraphic: View {
    private static let rows: [(color: Color, width: CGFloat)] = [(.orange, 96), (.purple, 72), (.blue, 110)]

    var body: some View {
        OnboardingSequencePlayer(count: Self.rows.count) { shownCount in
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(Self.rows.enumerated()), id: \.offset) { index, row in
                    let isDone = index < shownCount
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .strokeBorder(row.color, lineWidth: 3)
                            Circle()
                                .fill(row.color)
                                .scaleEffect(isDone ? 1 : 0)
                            Image(systemName: "checkmark")
                                .font(.footnote)
                                .fontWeight(.black)
                                .foregroundStyle(.white)
                                .scaleEffect(isDone ? 1 : 0)
                        }
                        .frame(width: 32, height: 32)
                        Capsule()
                            .fill(row.color.opacity(isDone ? 0.25 : 0.6))
                            .frame(width: row.width, height: 10)
                    }
                }
            }
        }
    }
}
