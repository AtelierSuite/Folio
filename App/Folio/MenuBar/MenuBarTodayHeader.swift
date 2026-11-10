#if os(macOS)
import SwiftUI

struct MenuBarTodayHeader: View {
    let day: Date
    let onOpenDay: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(day.formatted(.dateTime.weekday(.wide)))
                    .font(.caption)
                    .foregroundStyle(.red)
                    .textCase(.uppercase)
                Text(day.formatted(.dateTime.month(.wide).day()))
                    .font(.title3.bold())
            }
            Spacer()
            Button(String(localized: "Header.OpenFolio", table: "MenuBar"), systemImage: "macwindow", action: onOpenDay)
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .help(String(localized: "Header.OpenFolio", table: "MenuBar"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
#endif
