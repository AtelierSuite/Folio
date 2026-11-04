import SwiftUI

struct DuplicateCountBadge: View {
    let count: Int

    static func accessibilityDescription(count: Int) -> String {
        String(localized: "Duplicates.Count \(count)", table: "Calendar")
    }

    var body: some View {
        if count > 1 {
            Text(count, format: .number)
                .monospacedDigit()
                .lineLimit(1)
                .padding(.horizontal, 4)
                .background(.secondary.opacity(0.25), in: .capsule)
                .fixedSize()
                .accessibilityLabel(Self.accessibilityDescription(count: count))
        }
    }
}
