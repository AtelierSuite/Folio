import Foundation

extension MarkdownFrontMatter {
    public static let eventKey = "event"
    public static let dateKey = "date"
    public static let tagsKey = "tags"

    public var event: String? {
        get { value(forKey: Self.eventKey) }
        set { setValue(newValue, forKey: Self.eventKey) }
    }

    public var date: Date? {
        get { value(forKey: Self.dateKey).flatMap(YAMLDate.date(from:)) }
        set { setValue(newValue.map(YAMLDate.string(from:)), forKey: Self.dateKey) }
    }

    public var tags: [String] {
        get {
            guard let entry = entries.first(where: { $0.key == Self.tagsKey }) else { return [] }
            return YAMLSequence.values(of: entry.lines)
        }
        set {
            let tags = newValue.filter { !$0.isEmpty }
            guard !tags.isEmpty else {
                removeValue(forKey: Self.tagsKey)
                return
            }
            setLines(["\(Self.tagsKey): \(YAMLSequence.formatted(tags))"], forKey: Self.tagsKey)
        }
    }
}
