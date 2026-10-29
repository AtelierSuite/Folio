import AppIntents
import Foundation

public struct OpenEventIntent: OpenIntent {
    public static let title = LocalizedStringResource("OpenEventIntent.Title", table: "AppIntents", bundle: #bundle)

    @Parameter(title: LocalizedStringResource("OpenEventIntent.Event", table: "AppIntents", bundle: #bundle))
    public var target: EventEntity

    @Dependency private var requests: AppDestinationRequests

    public init() {}

    public init(target: EventEntity) {
        self.target = target
    }

    @MainActor
    public func perform() async throws -> some IntentResult {
        requests.open(.calendarDay(target.startDate, item: target.reference))
        return .result()
    }
}
