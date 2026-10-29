import AppIntents
import Foundation

/// Opens Folio to a new event, reminder or note; used by the Control Center controls. They run in the app,
/// and each kind is its own parameterless intent because controls dropped an enum parameter.
public struct NewEventIntent: AppIntent {
    public static let title = LocalizedStringResource("NewEventIntent.Title", table: "Intents", bundle: #bundle)
    public static let supportedModes: IntentModes = .foreground

    @Dependency private var requests: AppDestinationRequests

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult {
        requests.open(NewItemKind.event.destination)
        return .result()
    }
}

public struct NewReminderIntent: AppIntent {
    public static let title = LocalizedStringResource("NewReminderIntent.Title", table: "Intents", bundle: #bundle)
    public static let supportedModes: IntentModes = .foreground

    @Dependency private var requests: AppDestinationRequests

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult {
        requests.open(NewItemKind.reminder.destination)
        return .result()
    }
}

public struct NewNoteIntent: AppIntent {
    public static let title = LocalizedStringResource("NewNoteIntent.Title", table: "Intents", bundle: #bundle)
    public static let supportedModes: IntentModes = .foreground

    @Dependency private var requests: AppDestinationRequests

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult {
        requests.open(NewItemKind.note.destination)
        return .result()
    }
}
