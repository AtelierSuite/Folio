import Foundation

public struct AttendeeSummary: Sendable, Hashable {
    public let counts: [AttendeeResponse: Int]

    public init(_ attendees: [EventParticipant]) {
        counts = attendees.reduce(into: [:]) { counts, attendee in
            counts[attendee.status.response, default: 0] += 1
        }
    }

    public func count(of response: AttendeeResponse) -> Int {
        counts[response] ?? 0
    }

    public var total: Int {
        counts.values.reduce(0, +)
    }

    public func parts(locale: Locale = .current) -> [String] {
        AttendeeResponse.allCases.compactMap { response in
            let count = count(of: response)
            guard count > 0 else { return nil }
            let key: String.LocalizationValue = switch response {
            case .accepted: "Summary.Accepted \(count)"
            case .tentative: "Summary.Maybe \(count)"
            case .declined: "Summary.Declined \(count)"
            case .pending: "Summary.Pending \(count)"
            }
            let resource = LocalizedStringResource(
                key, table: "Invitations", locale: locale, bundle: .atURL(#bundle.bundleURL)
            )
            return String(localized: resource)
        }
    }

    public func description(locale: Locale = .current) -> String {
        parts(locale: locale).formatted(.list(type: .and, width: .narrow).locale(locale))
    }
}
