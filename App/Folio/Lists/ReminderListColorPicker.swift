import Planner
import SwiftUI

struct ReminderListColorPicker: View {
    @Binding var selection: PlannerColor

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 36), spacing: 12)], spacing: 12) {
            ForEach(Array(ReminderListPalette.colors.enumerated()), id: \.offset) { index, color in
                Button {
                    selection = color
                } label: {
                    Circle()
                        .fill(color.color)
                        .frame(width: 32, height: 32)
                        .padding(3)
                        .overlay {
                            if selection == color {
                                Circle().strokeBorder(.secondary, lineWidth: 2)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "NewList.Color.Option \(index + 1)", table: "Lists"))
                .accessibilityAddTraits(selection == color ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }
}
