import Planner
import SwiftUI

struct TimeZoneOptionRow: View {
    let option: TimeZoneOption
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(option.displayName)
                    .foregroundStyle(.primary)
                Text(option.regionName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(option.offset)
                .font(.callout)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            Image(systemName: "checkmark")
                .foregroundStyle(.tint)
                .opacity(isSelected ? 1 : 0)
                .accessibilityHidden(!isSelected)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
