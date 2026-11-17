import Foundation

public struct EnergyMarker: Sendable, Equatable {
    public enum Kind: Sendable, Equatable {
        case peak
        case dip
        case windDown
    }

    public let kind: Kind
    public let hour: Double

    public init(kind: Kind, hour: Double) {
        self.kind = kind
        self.hour = hour
    }
}
