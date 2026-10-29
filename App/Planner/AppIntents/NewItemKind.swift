import AppIntents
import Foundation

public enum NewItemKind: String, AppEnum, Sendable {
    case event
    case reminder
    case note

    public static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("NewItemKind.TypeName", table: "Intents", bundle: #bundle)
    )

    public static let caseDisplayRepresentations: [NewItemKind: DisplayRepresentation] = [
        .event: DisplayRepresentation(
            title: LocalizedStringResource("NewItemKind.Event", table: "Intents", bundle: #bundle),
            image: .init(systemName: "calendar.badge.plus")
        ),
        .reminder: DisplayRepresentation(
            title: LocalizedStringResource("NewItemKind.Reminder", table: "Intents", bundle: #bundle),
            image: .init(systemName: "checklist")
        ),
        .note: DisplayRepresentation(
            title: LocalizedStringResource("NewItemKind.Note", table: "Intents", bundle: #bundle),
            image: .init(systemName: "square.and.pencil")
        )
    ]

    public var destination: AppDestination {
        switch self {
        case .event: .newEvent
        case .reminder: .newReminder
        case .note: .newNote
        }
    }
}
