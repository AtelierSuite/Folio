import Contacts
import Foundation
import ImageIO
import UniformTypeIdentifiers

public protocol ContactBadgeReading: Sendable {
    func badge(for participant: EventParticipant) -> ContactBadge
}

/// Finds an attendee in Contacts by email. Without Contacts access, the event's own name is all there is.
public struct SystemContactBadgeReader: ContactBadgeReading {
    private static let thumbnailPixels = 96

    public init() {}

    public func badge(for participant: EventParticipant) -> ContactBadge {
        let fallback = ContactBadge(name: participant.displayName)
        guard Self.canReadContacts, let email = participant.emailAddress, let contact = contact(matching: email) else {
            return fallback
        }
        let name = PersonNameComponents(givenName: contact.givenName, familyName: contact.familyName)
        let formatted = name.formatted(.name(style: .abbreviated))
        return ContactBadge(
            initials: formatted.isEmpty ? fallback.initials : String(formatted.prefix(2)).uppercased(),
            thumbnail: contact.thumbnailImageData.flatMap(Self.resized)
        )
    }

    private static var canReadContacts: Bool {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined, .restricted, .denied: false
        default: true
        }
    }

    private func contact(matching email: String) -> CNContact? {
        let keys = [
            CNContactGivenNameKey, CNContactFamilyNameKey, CNContactThumbnailImageDataKey
        ] as [CNKeyDescriptor]
        let predicate = CNContact.predicateForContacts(matchingEmailAddress: email)
        return try? CNContactStore().unifiedContacts(matching: predicate, keysToFetch: keys).first
    }

    /// Widget entries are archived, so a badge carries a small image rather than the full thumbnail.
    private static func resized(_ data: Data) -> Data? {
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: thumbnailPixels
        ] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output, UTType.jpeg.identifier as CFString, 1, nil
        ) else { return nil }
        CGImageDestinationAddImage(destination, image, nil)
        return CGImageDestinationFinalize(destination) ? output as Data : nil
    }
}
