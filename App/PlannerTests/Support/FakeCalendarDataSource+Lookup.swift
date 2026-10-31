import Foundation
import Synchronization
@testable import Planner

extension FakeCalendarDataSource {
    @concurrent
    func containsEvent(matching reference: CalendarItemReference) async -> Bool? {
        state.withLock { state in
            state.events.contains { event in
                if let external = reference.externalIdentifier {
                    return event.reference.externalIdentifier == external
                }
                return event.reference.localIdentifier == reference.localIdentifier
            }
        }
    }
}
