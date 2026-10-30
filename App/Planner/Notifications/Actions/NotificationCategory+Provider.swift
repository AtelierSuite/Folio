import Foundation

/// Meeting categories get one variant per provider so the Join button can name the service.
extension NotificationCategory {
    var offersJoin: Bool {
        actions.contains(.joinMeeting)
    }

    public func identifier(joining provider: MeetingProvider?) -> String {
        guard offersJoin, let provider else { return rawValue }
        return "\(rawValue).\(provider.rawValue)"
    }
}
