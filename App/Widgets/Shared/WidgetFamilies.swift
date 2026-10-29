import WidgetKit

/// Lock Screen families don't exist on macOS, so they are only listed where WidgetKit has them.
enum WidgetFamilies {
    static let upNext: [WidgetFamily] = [.systemSmall, .systemMedium] + lockScreen
    static let today: [WidgetFamily] = [.systemMedium, .systemLarge, .systemExtraLarge]
    static let miniMonth: [WidgetFamily] = [.systemSmall, .systemMedium]
    static let reminders: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]

    private static var lockScreen: [WidgetFamily] {
        #if os(iOS)
        [.accessoryRectangular, .accessoryInline, .accessoryCircular]
        #else
        []
        #endif
    }
}
