import Foundation

public enum NotificationIdentifier {
    public static let prefix = "folio.alert."

    public static func isOwned(_ identifier: String) -> Bool {
        identifier.hasPrefix(prefix)
    }

    static func make(
        for candidate: NotificationCandidate,
        category: NotificationCategory,
        style: NotificationAlertStyle,
        sound: NotificationSound = .system
    ) -> String {
        let fireSeconds = Int(candidate.fireDate.timeIntervalSince1970.rounded(.down))
        let meetingURL = candidate.meeting.map { [$0.link.url.absoluteString] } ?? []
        let soundName = sound == .system ? [] : [sound.rawValue]
        let imagePath = candidate.imageURL.map { [$0.path(percentEncoded: false)] } ?? []
        let color = candidate.content.color.map { ["\($0.red),\($0.green),\($0.blue)"] } ?? []
        let origin = candidate.content.origin.map { [$0.accountName, $0.calendarName] } ?? []
        let time = candidate.content.time.map { [$0] } ?? []
        let fingerprint = ([candidate.content.title, candidate.content.body, category.rawValue, style.rawValue]
            + meetingURL + soundName + (candidate.place?.fingerprint ?? []) + imagePath + color + origin + time)
            .joined(separator: "\u{1F}")
        let item = "\(candidate.kind.rawValue).\(candidate.reference.storageKey)"
        return "\(prefix)\(item)@\(fireSeconds).\(stableDigest(of: fingerprint))"
    }

    // Swift's Hasher is seeded per launch, so identifiers use FNV-1a to stay stable across launches.
    static func stableDigest(of text: String) -> String {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01b3
        }
        return String(hash, radix: 16)
    }
}
