import AppIntents
import Foundation

/// Opens Folio to a fixed place; used by the Control Center controls.
public struct OpenTodayIntent: AppIntent {
    public static let title = LocalizedStringResource("OpenTodayIntent.Title", table: "Intents", bundle: #bundle)
    public static let supportedModes: IntentModes = .foreground

    @Dependency private var requests: AppDestinationRequests

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult {
        requests.open(.calendarDay(.now))
        return .result()
    }
}
