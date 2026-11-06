import Foundation

enum LeaveUrgency {
    case relaxed, soon, overdue
}

struct LeavePlan {
    var event: LabEvent
    var leaveAt: Date
    var minutesUntilLeaving: Int
    var needsUmbrella: Bool

    var urgency: LeaveUrgency {
        if minutesUntilLeaving <= 0 { return .overdue }
        return minutesUntilLeaving <= 15 ? .soon : .relaxed
    }
}

enum LeavePlanner {
    static func nextPlan(in snapshot: LabSnapshot) -> LeavePlan? {
        let upcoming = snapshot.eventsToday
            .filter { $0.travelMinutes != nil && $0.start > snapshot.now }
            .min { $0.start < $1.start }
        guard let event = upcoming, let travel = event.travelMinutes else { return nil }
        let leaveAt = event.start.addingTimeInterval(-Double(travel) * 60)
        return LeavePlan(
            event: event,
            leaveAt: leaveAt,
            minutesUntilLeaving: Int((leaveAt.timeIntervalSince(snapshot.now) / 60).rounded(.up)),
            needsUmbrella: snapshot.isRaining(at: leaveAt) || snapshot.isRaining(at: event.start)
        )
    }
}
