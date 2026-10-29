import Foundation

public protocol ArrivalNotifying: Sendable {
    func notify(_ candidate: ArrivalCandidate, at date: Date) async
}
