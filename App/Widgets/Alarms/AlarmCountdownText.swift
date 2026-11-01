#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import SwiftUI

struct AlarmCountdownText: View {
    let mode: AlarmPresentationState.Mode

    var body: some View {
        Group {
            switch mode {
            case .countdown(let countdown):
                Text(timerInterval: Date.now...max(.now, countdown.fireDate), countsDown: true)
            case .paused(let paused):
                Text(Duration.seconds(paused.totalCountdownDuration - paused.previouslyElapsedDuration)
                    .formatted(.time(pattern: .minuteSecond)))
            case .alert(let alert):
                Text(Calendar.current.date(
                    bySettingHour: alert.time.hour, minute: alert.time.minute, second: 0, of: .now
                ) ?? .now, style: .time)
            @unknown default:
                EmptyView()
            }
        }
        .monospacedDigit()
        .multilineTextAlignment(.trailing)
    }
}

struct AlarmModeIcon: View {
    let mode: AlarmPresentationState.Mode

    var body: some View {
        switch mode {
        case .countdown: Image(systemName: "zzz")
        default: Image(systemName: "alarm.fill")
        }
    }
}
#endif
