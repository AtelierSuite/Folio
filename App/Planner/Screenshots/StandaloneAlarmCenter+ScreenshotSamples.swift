#if DEBUG
import Foundation

extension StandaloneAlarmCenter {
    /// Replaces every alarm with the samples, on `day`. They show on the calendar even when AlarmKit can't ring them.
    public func seedScreenshotAlarms(
        _ samples: [ScreenshotSamples.SampleAlarm], on day: Date, calendar: Calendar
    ) async {
        storage.alarms = samples.compactMap { sample in
            calendar.date(bySettingHour: sample.hour, minute: sample.minute, second: 0, of: day).map {
                StandaloneAlarm(fireDate: $0, label: sample.label)
            }
        }
        await replan()
    }
}
#endif
