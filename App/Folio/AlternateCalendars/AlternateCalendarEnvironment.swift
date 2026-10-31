import Planner
import SwiftUI

struct AlternateCalendarEnvironment: ViewModifier {
    @Environment(SystemTimeObserver.self) private var systemTime
    @Environment(\.locale) private var locale
    @AppStorage(AlternateCalendar.storageKey) private var storedCalendar = ""

    func body(content: Content) -> some View {
        content.environment(\.alternateCalendarFormatter, formatter)
    }

    private var formatter: AlternateCalendarFormatter? {
        AlternateCalendar(rawValue: storedCalendar).map {
            AlternateCalendarFormatter(alternateCalendar: $0, timeZone: systemTime.timeZone, locale: locale)
        }
    }
}

extension View {
    func providesAlternateCalendar() -> some View {
        modifier(AlternateCalendarEnvironment())
    }
}
