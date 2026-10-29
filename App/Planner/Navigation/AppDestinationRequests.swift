import Foundation
import Observation

/// Lets App Intents that run in the app, such as the Control Center controls, ask it to open a destination;
/// the app forwards the request to the scene's router.
@MainActor
@Observable
public final class AppDestinationRequests {
    public var pendingDestination: AppDestination?

    public init() {}

    public func open(_ destination: AppDestination) {
        pendingDestination = destination
    }
}
