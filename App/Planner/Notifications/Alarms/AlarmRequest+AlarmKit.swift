#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import Foundation
import SwiftUI

extension AlarmRequest {
    /// AlarmKit draws alarms outside Folio, so text is resolved here and handed over as is.
    private static func verbatim(_ text: String) -> LocalizedStringResource {
        LocalizedStringResource("\(text)")
    }

    private static func localized(_ key: String.LocalizationValue) -> LocalizedStringResource {
        verbatim(String(localized: key, table: "Alarms", bundle: #bundle))
    }

    private var tintColor: Color {
        tint?.color ?? .accentColor
    }

    var alarmConfiguration: AlarmManager.AlarmConfiguration<FolioAlarmMetadata> {
        switch secondaryAction {
        case .snooze(let duration):
            AlarmManager.AlarmConfiguration(
                countdownDuration: Alarm.CountdownDuration(preAlert: nil, postAlert: duration),
                schedule: .fixed(fireDate),
                attributes: attributes(
                    button: AlarmButton(
                        text: Self.localized("Button.Snooze"), textColor: tintColor, systemImageName: "zzz"
                    ),
                    behavior: .countdown
                )
            )
        case .open:
            AlarmManager.AlarmConfiguration(
                schedule: .fixed(fireDate),
                attributes: attributes(
                    button: AlarmButton(
                        text: Self.localized("Button.Open"),
                        textColor: tintColor,
                        systemImageName: "arrow.up.forward.app"
                    ),
                    behavior: .custom
                ),
                secondaryIntent: OpenAlarmItemIntent(link: link)
            )
        }
    }

    private func attributes(
        button: AlarmButton,
        behavior: AlarmPresentation.Alert.SecondaryButtonBehavior
    ) -> AlarmAttributes<FolioAlarmMetadata> {
        let alert = AlarmPresentation.Alert(
            title: Self.verbatim(title), secondaryButton: button, secondaryButtonBehavior: behavior
        )
        let countdown = behavior == .countdown ? AlarmPresentation.Countdown(title: Self.verbatim(title)) : nil
        return AlarmAttributes(
            presentation: AlarmPresentation(alert: alert, countdown: countdown),
            metadata: FolioAlarmMetadata(self),
            tintColor: tintColor
        )
    }
}
#endif
