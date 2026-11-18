import Contacts
import Foundation

public struct BirthdayContact: Sendable, Hashable {
    public let identifier: String
    public let name: String
    public let birthYear: Int?
    public let thumbnail: Data?

    public init(identifier: String, name: String, birthYear: Int? = nil, thumbnail: Data? = nil) {
        self.identifier = identifier
        self.name = name
        self.birthYear = birthYear
        self.thumbnail = thumbnail
    }

    /// Birthdays calendar events fall on Gregorian dates, so the age is counted in Gregorian years
    /// even when the device uses another calendar.
    public func age(on date: Date, timeZone: TimeZone = .current) -> Int? {
        guard let birthYear else { return nil }
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = timeZone
        let age = gregorian.component(.year, from: date) - birthYear
        return age > 0 ? age : nil
    }
}

public enum BirthdayContactLookup: Sendable, Hashable {
    case found(BirthdayContact)
    /// Folio may read some contacts, but not this one.
    case notShared
    case noAccess
}

/// Finds the person a Birthdays calendar event was made for. Needs Contacts access.
public struct BirthdayContactReader: Sendable {
    private let canReadContacts: @Sendable () -> Bool
    private let fetch: @Sendable (String) -> CNContact?

    public init() {
        self.init(
            canReadContacts: {
                switch CNContactStore.authorizationStatus(for: .contacts) {
                case .notDetermined, .restricted, .denied: false
                default: true
                }
            },
            fetch: { identifier in
                let keys = [
                    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactBirthdayKey as CNKeyDescriptor,
                    CNContactThumbnailImageDataKey as CNKeyDescriptor
                ]
                return try? CNContactStore().unifiedContact(withIdentifier: identifier, keysToFetch: keys)
            }
        )
    }

    init(canReadContacts: @escaping @Sendable () -> Bool, fetch: @escaping @Sendable (String) -> CNContact?) {
        self.canReadContacts = canReadContacts
        self.fetch = fetch
    }

    public func lookUp(_ identifier: String) -> BirthdayContactLookup {
        guard canReadContacts() else { return .noAccess }
        guard let contact = fetch(identifier) else { return .notShared }
        let name = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
        let year = contact.isKeyAvailable(CNContactBirthdayKey) ? contact.birthday?.year : nil
        return .found(BirthdayContact(
            identifier: contact.identifier,
            name: name,
            birthYear: year == NSDateComponentUndefined ? nil : year,
            thumbnail: contact.isKeyAvailable(CNContactThumbnailImageDataKey) ? contact.thumbnailImageData : nil
        ))
    }
}
