import Foundation

public enum AlarmIdentifier {
    public static func make(for alarm: PlannedNotification) -> UUID {
        make(fromNotificationIdentifier: alarm.id)
    }

    static func make(fromNotificationIdentifier identifier: String) -> UUID {
        let high = digest(of: identifier, seed: 0xcbf2_9ce4_8422_2325)
        let low = digest(of: identifier, seed: 0x8422_2325_cbf2_9ce4)
        var bytes = withUnsafeBytes(of: high.bigEndian, Array.init) + withUnsafeBytes(of: low.bigEndian, Array.init)
        bytes[6] = (bytes[6] & 0x0F) | 0x50
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }

    private static func digest(of text: String, seed: UInt64) -> UInt64 {
        var hash = seed
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01b3
        }
        return hash
    }
}
