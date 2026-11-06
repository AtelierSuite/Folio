import Foundation

enum LabFormat {
    static func time(_ date: Date) -> String {
        date.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute())
    }

    static func weekday(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }

    static func duration(minutes: Int) -> String {
        let hours = minutes / 60
        let remainder = minutes % 60
        if hours == 0 { return "\(remainder)m" }
        return remainder == 0 ? "\(hours)h" : "\(hours)h \(remainder)m"
    }

    static func count(_ value: Int, _ noun: String) -> String {
        "\(value) \(noun)\(value == 1 ? "" : "s")"
    }

    static func minutes(from start: Date, to end: Date) -> Int {
        Int((end.timeIntervalSince(start) / 60).rounded())
    }

    /// Real values from Foundation, so the almanac shows what `AlternateCalendarFormatter` could.
    static func japaneseEra(_ date: Date) -> String {
        var style = Date.FormatStyle.dateTime.era().year().locale(Locale(identifier: "ja_JP"))
        style.calendar = Calendar(identifier: .japanese)
        return date.formatted(style)
    }

    static func lunarDate(_ date: Date) -> String {
        let lunar = Calendar(identifier: .chinese).dateComponents([.month, .day], from: date)
        return "旧暦 \(lunar.month ?? 0)月\(lunar.day ?? 0)日"
    }
}
