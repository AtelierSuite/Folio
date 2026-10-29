import AppIntents
import Foundation

/// Opens Folio to a new event, reminder or note, used by the Control Center controls.
public struct OpenComposerIntent: AppIntent {
    public static let title = LocalizedStringResource("OpenComposerIntent.Title", table: "Intents", bundle: #bundle)
    public static let supportedModes: IntentModes = .foreground

    @Parameter(title: LocalizedStringResource("OpenComposerIntent.Kind", table: "Intents", bundle: #bundle))
    public var kind: NewItemKind

    public init() {}

    public init(kind: NewItemKind) {
        self.kind = kind
    }

    public func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(CalendarDeepLink.url(forNew: kind)))
    }
}
