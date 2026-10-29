import Foundation

/// Daily notes live at `Daily/yyyy-MM-dd.md`. The day is always written in the Gregorian calendar,
/// whatever calendar the user picked, so the files sort and match on every device.
public enum DailyNoteNaming {
    public static let folderName = "Daily"

    public static func dayKey(for date: Date, timeZone: TimeZone = .current) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    public static func relativePath(for date: Date, timeZone: TimeZone = .current) -> String {
        "\(folderName)/\(dayKey(for: date, timeZone: timeZone)).\(NoteFileNaming.noteExtension)"
    }

    static func dayKey(ofRelativePath relativePath: String) -> String? {
        let components = relativePath.split(separator: "/")
        guard components.count == 2, components[0] == folderName else {
            return nil
        }
        let name = (String(components[1]) as NSString).deletingPathExtension
        let pattern = /^\d{4}-\d{2}-\d{2}$/
        return name.wholeMatch(of: pattern) != nil ? name : nil
    }
}
