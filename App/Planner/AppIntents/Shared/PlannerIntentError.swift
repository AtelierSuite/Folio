import Foundation

/// The errors App Intents report to Siri and Shortcuts, worded for someone who can't see the app.
public enum PlannerIntentError: Error, Sendable, Equatable, CustomLocalizedStringResourceConvertible {
    case noCalendarAccess
    case noReminderAccess
    case eventNotFound
    case reminderNotFound
    case noteNotFound
    case readOnly
    case noWritableCalendar
    case noWritableReminderList
    case invalidDates
    case emptyTitle
    case notesUnavailable

    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .noCalendarAccess: Self.resource("Error.NoCalendarAccess")
        case .noReminderAccess: Self.resource("Error.NoReminderAccess")
        case .eventNotFound: Self.resource("Error.EventNotFound")
        case .reminderNotFound: Self.resource("Error.ReminderNotFound")
        case .noteNotFound: Self.resource("Error.NoteNotFound")
        case .readOnly: Self.resource("Error.ReadOnly")
        case .noWritableCalendar: Self.resource("Error.NoWritableCalendar")
        case .noWritableReminderList: Self.resource("Error.NoWritableReminderList")
        case .invalidDates: Self.resource("Error.InvalidDates")
        case .emptyTitle: Self.resource("Error.EmptyTitle")
        case .notesUnavailable: Self.resource("Error.NotesUnavailable")
        }
    }

    private static func resource(_ key: String.LocalizationValue) -> LocalizedStringResource {
        LocalizedStringResource(key, table: "AppIntents", bundle: #bundle)
    }

    init(_ error: EventEditingError) {
        switch error {
        case .readOnly: self = .readOnly
        case .noWritableCalendar: self = .noWritableCalendar
        case .invalidDates: self = .invalidDates
        }
    }

    init(_ error: ReminderEditingError) {
        switch error {
        case .invalidDraft: self = .emptyTitle
        case .readOnly: self = .readOnly
        case .listNotFound, .accountNotFound: self = .noWritableReminderList
        }
    }
}

extension PlannerIntentError {
    /// Runs a store call, rewording the editing errors it throws for Siri.
    static func rewording<Value>(
        notFound: PlannerIntentError,
        _ operation: () async throws -> Value
    ) async throws -> Value {
        do {
            return try await operation()
        } catch let error as EventEditingError {
            throw PlannerIntentError(error)
        } catch let error as ReminderEditingError {
            throw PlannerIntentError(error)
        } catch CalendarDataSourceError.itemNotFound {
            throw notFound
        }
    }
}
