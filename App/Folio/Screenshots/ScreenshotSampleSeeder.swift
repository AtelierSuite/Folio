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
        let samples = ScreenshotSamples.current
        if arguments.contains(ScreenshotSamples.launchArgument) {
            await seed(samples, notesLibrary: notesLibrary, standaloneAlarms: standaloneAlarms)
        }
        if ScreenshotStage.isActive {
            await applySettings(of: samples, calendarStore: calendarStore, notificationScheduler: notificationScheduler)
        }
    }

    private static func seed(
        _ samples: ScreenshotSamples, notesLibrary: NotesLibrary, standaloneAlarms: StandaloneAlarmCenter
    ) async {
        let calendar = Calendar.current
        let alarmDay = ScreenshotSamples.nextWeekday(after: .now, calendar: calendar)
        await standaloneAlarms.seedScreenshotAlarms(samples.alarms, on: alarmDay, calendar: calendar)
        do {
            try await notesLibrary.seedScreenshotNotes(samples.notes)
        } catch {
            log("Seeding the screenshot notes failed: \(error.localizedDescription)")
        }
        #if targetEnvironment(simulator)
        let removesOtherCalendars = true
        #else
        let removesOtherCalendars = false
        #endif
        do {
            _ = try await EventKitDataSource.shared.seedScreenshotSamples(
                samples,
                removesOtherCalendars: removesOtherCalendars,
                includesCountdown: PlatformCapabilities.current.supports(.liveActivityCountdown),
                calendar: calendar
            )
        } catch {
            log("Seeding the screenshot calendars failed: \(error.localizedDescription)")
        }
    }

    private static func log(_ message: String) {
        Logger(subsystem: "com.tsubuzaki.Folio", category: "Screenshots").error("\(message, privacy: .public)")
    }

    /// Gives each sample calendar its alert style, and keeps holidays, birthdays and anything else off the calendar
    /// with a plain alert. Done on every screenshot launch: these live in the App Group, which an ad hoc build in the
    /// Mac VM can't keep from one launch to the next.
    private static func applySettings(
        of samples: ScreenshotSamples, calendarStore: CalendarStore, notificationScheduler: NotificationScheduler
    ) async {
        for kind in CalendarItemKind.allCases {
            for calendar in EventKitDataSource.shared.calendars(for: kind) {
                let sample = samples.calendars.first { $0.kind == kind && $0.title == calendar.title }
                if sample == nil, calendarStore.isVisible(calendar) {
                    calendarStore.setVisible(false, for: calendar)
                }
                await notificationScheduler.setDefaultStyle(sample?.alertStyle ?? .standard, forCalendar: calendar.id)
            }
        }
    }
}
#endif
