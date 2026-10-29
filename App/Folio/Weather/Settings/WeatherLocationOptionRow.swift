import SwiftUI

struct WeatherLocationOptionRow: View {
    let title: String
    var systemImage: String?
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            HStack {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
