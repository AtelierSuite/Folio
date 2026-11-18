import SwiftUI

struct BirthdayGlyph: View {
    var body: some View {
        Image(systemName: BirthdayStyle.symbolName)
            .symbolRenderingMode(.palette)
            .foregroundStyle(BirthdayStyle.confetti, BirthdayStyle.cone)
            .accessibilityLabel(String(localized: "Accessibility.Birthday", table: "Birthdays"))
    }
}
