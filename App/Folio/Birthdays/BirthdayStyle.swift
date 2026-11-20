import SwiftUI

enum BirthdayStyle {
    static let symbolName = "party.popper.fill"
    static let circleGlyphOffset = CGSize(width: 0.03, height: -0.03)
    static let circleGlyphScale: CGFloat = 0.45
    static let cone = Color(red: 1, green: 0.37, blue: 0.64)
    static let confetti = Color(red: 1, green: 0.72, blue: 0)
    static let text = Color.pink

    static let fill = LinearGradient(
        colors: [cone.opacity(0.32), confetti.opacity(0.28)],
        startPoint: .leading,
        endPoint: .trailing
    )
}
