#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import SwiftUI

struct AlarmLockScreenView: View {
    let title: String
    let mode: AlarmPresentationState.Mode
    let tint: Color

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            AlarmModeIcon(mode: mode)
                .font(.title2)
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Snoozed", table: "Alarms"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            AlarmCountdownText(mode: mode)
                .font(.title.weight(.semibold))
                .frame(maxWidth: 140, alignment: .trailing)
        }
        .padding(16)
    }
}
#endif
