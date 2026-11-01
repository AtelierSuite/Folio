import Foundation

extension NotificationScheduler {
    func dismissEndedNotifications(at now: Date) async {
        let ended = await center.deliveredEndDates()
            .filter { $0.value <= now }
            .map(\.key)
        await center.removeDelivered(withIdentifiers: ended)
    }
}
