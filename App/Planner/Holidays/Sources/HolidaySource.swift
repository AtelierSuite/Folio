import Foundation

/// Government publications where a country offers one, Nager.Date's public holiday API elsewhere.
public enum HolidaySource: Hashable, Sendable {
    case cabinetOfficeJapan
    case govUK
    case nagerDate(regionCode: String)

    public init?(regionCode: String) {
        switch regionCode.uppercased() {
        case "JP": self = .cabinetOfficeJapan
        case "GB": self = .govUK
        case let code where Self.nagerDateRegionCodes.contains(code): self = .nagerDate(regionCode: code)
        default: return nil
        }
    }

    public static var supportedRegionCodes: Set<String> {
        nagerDateRegionCodes.union(["JP", "GB"])
    }

    public var isGovernmentPublication: Bool {
        switch self {
        case .cabinetOfficeJapan, .govUK: true
        case .nagerDate: false
        }
    }

    var cacheKey: String {
        switch self {
        case .cabinetOfficeJapan: "cao-jp"
        case .govUK: "gov-uk"
        case .nagerDate(let regionCode): "nager-\(regionCode.lowercased())"
        }
    }

    func urls(for years: ClosedRange<Int>) -> [URL] {
        switch self {
        case .cabinetOfficeJapan:
            [URL(string: "https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv")].compactMap(\.self)
        case .govUK:
            [URL(string: "https://www.gov.uk/bank-holidays.json")].compactMap(\.self)
        case .nagerDate(let regionCode):
            years.compactMap { URL(string: "https://date.nager.at/api/v3/PublicHolidays/\($0)/\(regionCode)") }
        }
    }

    func holidays(from data: Data) throws -> [Holiday] {
        switch self {
        case .cabinetOfficeJapan: try CabinetOfficeHolidayParser.holidays(from: data)
        case .govUK: try GovUKHolidayParser.holidays(from: data)
        case .nagerDate: try NagerDateHolidayParser.holidays(from: data)
        }
    }
}
