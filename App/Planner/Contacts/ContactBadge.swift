import CoreGraphics
import Foundation
import ImageIO

/// What stands for a person on a small badge: their photo when Contacts has one, otherwise their initials.
public struct ContactBadge: Sendable, Hashable {
    public let initials: String
    public let thumbnail: Data?

    public init(initials: String, thumbnail: Data? = nil) {
        self.initials = initials
        self.thumbnail = thumbnail
    }

    public init(name: String, thumbnail: Data? = nil) {
        self.init(initials: Self.initials(from: name), thumbnail: thumbnail)
    }

    public var image: CGImage? {
        guard let thumbnail, let source = CGImageSourceCreateWithData(thumbnail as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    static func initials(from name: String) -> String {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .abbreviated
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let components = formatter.personNameComponents(from: trimmed) {
            let abbreviated = formatter.string(from: components)
            if !abbreviated.isEmpty {
                return String(abbreviated.prefix(2)).uppercased()
            }
        }
        return String(trimmed.prefix(1)).uppercased()
    }
}
