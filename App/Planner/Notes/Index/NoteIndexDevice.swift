import Foundation

/// Names this installation, so links to notes stored only on this device never match notes on another.
enum NoteIndexDevice {
    private static let identifierKey = "NoteIndex.DeviceIdentifier"

    static func identifier(in defaults: UserDefaults = AppGroup.userDefaults) -> String {
        if let identifier = defaults.string(forKey: identifierKey) {
            return identifier
        }
        let identifier = UUID().uuidString
        defaults.set(identifier, forKey: identifierKey)
        return identifier
    }
}
