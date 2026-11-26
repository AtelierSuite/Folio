#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import AppIntents
import Planner
import SwiftUI

struct AlarmStopButton: View {
    let alarmIdentifier: UUID
    let tint: Color

    var body: some View {
        Button(intent: StopAlarmIntent(alarmIdentifier: alarmIdentifier)) {
            Label(String(localized: "Button.Stop", table: "Alarms"), systemImage: "xmark")
                .labelStyle(.iconOnly)
                .font(.body.weight(.semibold))
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(tint, in: .circle)
    }
}
#endif
