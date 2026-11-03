#if canImport(AlarmKit) && os(iOS)
import AlarmKit
import AppIntents
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
            configuration(
                countdownDuration: Alarm.CountdownDuration(preAlert: nil, postAlert: duration),
                attributes: attributes(
                    button: AlarmButton(
                        text: Self.localized("Button.Snooze"), textColor: .white, systemImageName: "zzz"
                    ),
                    behavior: .countdown
                ),
                secondaryIntent: nil
            )
        case .open:
            configuration(
                countdownDuration: nil,
                attributes: attributes(
                    button: AlarmButton(
                        text: Self.localized("Button.Open"),
                        textColor: .white,
                        systemImageName: "arrow.up.forward.app"
                    ),
                    behavior: .custom
                ),
                secondaryIntent: link.map(OpenAlarmItemIntent.init(link:))
            )
        }
    }

    private func configuration(
        countdownDuration: Alarm.CountdownDuration?,
        attributes: AlarmAttributes<FolioAlarmMetadata>,
        secondaryIntent: (any LiveActivityIntent)?
    ) -> AlarmManager.AlarmConfiguration<FolioAlarmMetadata> {
        if #available(iOS 27, *), let entityIdentifier {
            return AlarmManager.AlarmConfiguration(
                countdownDuration: countdownDuration,
                schedule: .fixed(fireDate),
                attributes: attributes,
                appEntityIdentifier: entityIdentifier,
                secondaryIntent: secondaryIntent
            )
        }
        return AlarmManager.AlarmConfiguration(
            countdownDuration: countdownDuration,
            schedule: .fixed(fireDate),
            attributes: attributes,
            secondaryIntent: secondaryIntent
        )
    }

    private var entityIdentifier: EntityIdentifier? {
        guard let item else { return nil }
        return switch item.kind {
        case .event: EntityIdentifier(for: EventEntity.self, identifier: item.reference.storageKey)
        case .reminder: EntityIdentifier(for: ReminderEntity.self, identifier: item.reference.storageKey)
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
