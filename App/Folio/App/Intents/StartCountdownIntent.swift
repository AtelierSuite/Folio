#if os(iOS)
import AppIntents
import Planner

/// Siri and Shortcuts can start a countdown to the next event, but only within the same
/// 8-hour window as the button in the event detail view.
struct StartCountdownIntent: LiveActivityIntent {
    static let title = LocalizedStringResource("StartCountdownIntent.Title", table: "Countdown")
    static let description = IntentDescription(
        LocalizedStringResource("StartCountdownIntent.Description", table: "Countdown")
    )

    @Dependency private var countdowns: EventCountdownManager

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard PlatformCapabilities.current.supports(.liveActivityCountdown) else {
            throw StartCountdownIntentError.unavailable
        }
        do {
            let event = try await countdowns.startNextCountdown()
            return .result(dialog: IntentDialog(
                LocalizedStringResource("StartCountdownIntent.Started \(event.title)", table: "Countdown")
            ))
        } catch CountdownActivityError.noUpcomingEvent {
            throw StartCountdownIntentError.noUpcomingEvent
        } catch {
            throw StartCountdownIntentError.unavailable
        }
    }
}

enum StartCountdownIntentError: Error, CustomLocalizedStringResourceConvertible {
    case noUpcomingEvent
    case unavailable

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .noUpcomingEvent: LocalizedStringResource("StartCountdownIntent.NoEvent", table: "Countdown")
        case .unavailable: LocalizedStringResource("StartCountdownIntent.Unavailable", table: "Countdown")
        }
    }
}
#endif
