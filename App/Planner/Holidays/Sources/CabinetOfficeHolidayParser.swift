import Foundation

/// Parses the Cabinet Office's `syukujitsu.csv`: Shift_JIS, a header row, then `yyyy/M/d,名称` rows.
enum CabinetOfficeHolidayParser {
    static func holidays(from data: Data) throws -> [Holiday] {
        guard let text = String(data: data, encoding: .shiftJIS) ?? String(data: data, encoding: .utf8) else {
            throw HolidaySourceError.unreadableData
        }
        return text.split(whereSeparator: \.isNewline).compactMap { line in
            let columns = line.split(separator: ",", maxSplits: 1)
            guard columns.count == 2,
                  let day = HolidayDay(separatedDate: columns[0], separator: "/") else { return nil }
            return Holiday(day: day, name: columns[1].trimmingCharacters(in: .whitespaces))
        }
    }
}
