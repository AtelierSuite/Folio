#if canImport(AlarmKit) && os(iOS)
import AppIntents
import Foundation

/// The Open button on an alarm, which brings Folio forward to the event or reminder it rang for.
public struct OpenAlarmItemIntent: LiveActivityIntent {
    public static let title = LocalizedStringResource("Intent.OpenItem", table: "Alarms", bundle: #bundle)
    public static let supportedModes: IntentModes = .foreground
    public static let isDiscoverable = false

    @Parameter(title: LocalizedStringResource("Intent.OpenItem.Link", table: "Alarms", bundle: #bundle))
    public var link: URL

    @Dependency private var requests: AppDestinationRequests

    public init() {}

    public init(link: URL) {
        self.link = link
    }

    @MainActor
    public func perform() async throws -> some IntentResult {
        if let destination = CalendarDeepLink.destination(from: link) {
            requests.open(destination)
        }
        return .result()
    }
}
#endif
