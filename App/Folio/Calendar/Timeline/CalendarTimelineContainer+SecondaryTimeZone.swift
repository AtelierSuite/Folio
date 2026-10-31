import Planner
import SwiftUI

extension CalendarTimelineContainer {
    var secondaryTimeZoneLayers: [TimelineLayer] {
        guard let timeZone = SecondaryTimeZoneSettings.shownTimeZone(
            isEnabled: showsSecondaryTimeZone,
            identifier: secondaryTimeZoneIdentifier
        ) else { return [] }
        let label = TimeZoneOption(identifier: timeZone.identifier)?.columnLabel ?? timeZone.identifier
        return [.secondaryTimeZone(timeZone, label: label)]
    }
}
