#if DEBUG
import Foundation

extension WakeUpAlarmCenter {
    /// Rings the next wake-up alarm early, to check how it looks, snoozes and opens.
    public func ringNextAlarmSoon(after delay: TimeInterval = 10) async {
        guard let event = upcomingAlarms.first?.event else { return }
        let alarm = WakeUpAlarm(event: event, fireDate: clock().addingTimeInterval(delay))
        try? await alarmClient.schedule(alarm.request(formatter: formatter))
    }
}
#endif
