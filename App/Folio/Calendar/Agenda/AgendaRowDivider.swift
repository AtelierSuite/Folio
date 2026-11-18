import SwiftUI

struct AgendaRowDivider: View {
    @Environment(\.displayScale) private var displayScale
    var leadingInset: CGFloat = 0

    var body: some View {
        Rectangle()
            .fill(.separator)
            .frame(height: 1 / displayScale)
            .padding(.leading, leadingInset)
            .accessibilityHidden(true)
    }
}
