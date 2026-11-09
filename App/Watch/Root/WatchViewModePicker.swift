import SwiftUI

struct WatchViewModePicker: View {
    @Binding var mode: WatchViewMode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(WatchViewMode.allCases) { option in
            Button {
                mode = option
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: option.systemImage)
                        .frame(width: 22)
                        .foregroundStyle(.tint)
                    Text(option.title)
                    Spacer(minLength: 0)
                    if option == mode {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "Mode.Picker.Title", table: "Watch"))
    }
}
