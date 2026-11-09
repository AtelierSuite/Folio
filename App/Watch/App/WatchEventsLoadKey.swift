import Foundation

/// What a view's events depend on, so its loading task reruns when any of it changes.
struct WatchEventsLoadKey: Hashable {
    let firstDay: Date
    let dayCount: Int
    let revision: Int
}
