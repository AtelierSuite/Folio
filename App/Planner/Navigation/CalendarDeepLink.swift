import Foundation

/// `folio://` links for calendar destinations, used by widgets and controls:
/// `folio://day/2026-10-29`, `folio://event/<id>?calendar=…&start=…` and `folio://new/event|reminder|note`.
public enum CalendarDeepLink {
    static let scheme = "folio"

    public static func url(forDay date: Date, calendar: Calendar = .current) -> URL {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let day = String(
            format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0
        )
        return makeURL(host: "day", path: "/\(day)")
    }

    public static func url(for event: CalendarEvent) -> URL {
        url(forEvent: event.reference, startingAt: event.startDate)
    }

    public static func url(forEvent reference: CalendarItemReference, startingAt startDate: Date) -> URL {
        var queryItems = [
            URLQueryItem(name: "calendar", value: reference.calendarIdentifier),
            URLQueryItem(name: "title", value: reference.title),
            URLQueryItem(name: "start", value: timestamp(startDate))
        ]
        if let externalIdentifier = reference.externalIdentifier {
            queryItems.append(URLQueryItem(name: "external", value: externalIdentifier))
        }
        if let occurrenceDate = reference.occurrenceDate {
            queryItems.append(URLQueryItem(name: "occurrence", value: timestamp(occurrenceDate)))
        }
        return makeURL(host: "event", path: "/\(reference.localIdentifier)", queryItems: queryItems)
    }

    public static func url(forNew kind: NewItemKind) -> URL {
        makeURL(host: "new", path: "/\(kind.rawValue)")
    }

    public static func destination(from url: URL, calendar: Calendar = .current) -> AppDestination? {
        guard url.scheme?.lowercased() == scheme,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        let pathValue = String(components.path.dropFirst())
        switch components.host?.lowercased() {
        case "day":
            return day(from: pathValue, calendar: calendar).map { .calendarDay($0) }
        case "event":
            return eventDestination(localIdentifier: pathValue, queryItems: components.queryItems ?? [])
        case "new":
            return NewItemKind(rawValue: pathValue.lowercased())?.destination
        default:
            return nil
        }
    }

    private static func eventDestination(localIdentifier: String, queryItems: [URLQueryItem]) -> AppDestination? {
        func value(_ name: String) -> String? {
            queryItems.first { $0.name == name }?.value
        }
        guard !localIdentifier.isEmpty, let start = value("start").flatMap(date(fromTimestamp:)) else { return nil }
        let reference = CalendarItemReference(
            externalIdentifier: value("external"),
            localIdentifier: localIdentifier,
            calendarIdentifier: value("calendar") ?? "",
            occurrenceDate: value("occurrence").flatMap(date(fromTimestamp:)),
            title: value("title") ?? "",
            startDate: start
        )
        return .calendarDay(start, item: reference)
    }

    private static func day(from value: String, calendar: Calendar) -> Date? {
        let parts = value.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }

    private static func makeURL(host: String, path: String, queryItems: [URLQueryItem] = []) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url ?? URL(string: "\(scheme)://")!
    }

    private static func timestamp(_ date: Date) -> String {
        String(Int(date.timeIntervalSince1970.rounded()))
    }

    private static func date(fromTimestamp value: String) -> Date? {
        TimeInterval(value).map(Date.init(timeIntervalSince1970:))
    }
}
