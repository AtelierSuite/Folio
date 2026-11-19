import Foundation

public struct DirectionsRequest: Sendable, Hashable {
    public let destination: DirectionsDestination
    /// `nil` leaves the choice of transport to the maps app.
    public let transport: TravelTransport?

    public init(destination: DirectionsDestination, transport: TravelTransport? = nil) {
        self.destination = destination
        self.transport = transport
    }
}
