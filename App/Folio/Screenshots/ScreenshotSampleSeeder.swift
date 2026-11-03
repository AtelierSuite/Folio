#if DEBUG
import OSLog
import Planner

/// Fills a screenshot device with `ScreenshotSamples`, in the language the app runs in.
@MainActor
enum ScreenshotSampleSeeder {
    static func seedIfRequested(
        arguments: [String],
        calendarStore: CalendarStore,
        notesLibrary: NotesLibrary,
        standaloneAlarms: StandaloneAlarmCenter,
        notificationScheduler: NotificationScheduler
    ) async {
        guard arguments.contains(ScreenshotSamples.launchArgument) else { return }
        let samples = ScreenshotSamples.current
        let calendar = Calendar.current
        do {
            #if targetEnvironment(simulator)
            let removesOtherCalendars = true
            #else
            let removesOtherCalendars = false
            #endif
            let identifiers = try await EventKitDataSource.shared.seedScreenshotSamples(
                samples, removesOtherCalendars: removesOtherCalendars, calendar: calendar
            )
            for sample in samples.calendars {
                if let identifier = identifiers[sample.key] {
                    await notificationScheduler.setDefaultStyle(sample.alertStyle, forCalendar: identifier)
                }
            }
            // Holidays, birthdays and whatever else can't be removed stay off the calendar, and alert plainly.
            let sampleIdentifiers = Set(identifiers.values)
            for kind in CalendarItemKind.allCases {
                let calendars = EventKitDataSource.shared.calendars(for: kind)
                for other in calendars where !sampleIdentifiers.contains(other.id) {
                    calendarStore.setVisible(false, for: other)
                    if removesOtherCalendars {
                        await notificationScheduler.setDefaultStyle(.standard, forCalendar: other.id)
                    }
                }
            }
            try await notesLibrary.seedScreenshotNotes(samples.notes)
        } catch {
            Logger(subsystem: "com.tsubuzaki.Folio", category: "Screenshots")
                .error("Seeding the screenshot samples failed: \(error.localizedDescription, privacy: .public)")
        }
        let alarmDay = ScreenshotSamples.nextWeekday(after: .now, calendar: calendar)
        await standaloneAlarms.seedScreenshotAlarms(samples.alarms, on: alarmDay, calendar: calendar)
    }
}
#endif
