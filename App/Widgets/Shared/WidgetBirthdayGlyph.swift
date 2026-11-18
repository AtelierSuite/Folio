import SwiftUI

struct WidgetBirthdayGlyph: View {
    var body: some View {
        Image(systemName: "party.popper.fill")
            .symbolRenderingMode(.palette)
            .foregroundStyle(Color(red: 1, green: 0.72, blue: 0), Color(red: 1, green: 0.37, blue: 0.64))
            .accessibilityLabel(String(localized: "Birthday", table: "Widgets"))
    }
}
