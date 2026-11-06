import WidgetKit

/// Lock Screen families don't exist on macOS, so they are only listed where WidgetKit has them.
enum WidgetFamilies {
    static let upNext: [WidgetFamily] = [.systemSmall, .systemMedium] + lockScreen
    static let today: [WidgetFamily] = [.systemMedium, .systemLarge, .systemExtraLarge]
    static let hourly: [WidgetFamily] = [.systemMedium]
    static let miniMonth: [WidgetFamily] = [.systemSmall, .systemMedium]
    static let reminders: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]

    static let leaveBy: [WidgetFamily] = [.systemSmall, .systemMedium] + lockScreenGlance
    static let inbox: [WidgetFamily] = [.systemMedium, .systemLarge] + lockScreenCount
    static let eventNotes: [WidgetFamily] = [.systemMedium, .systemLarge]
    static let dayShift: [WidgetFamily] = [.systemSmall, .systemMedium]
    static let dayLoad: [WidgetFamily] = [.systemSmall, .systemMedium] + lockScreenText

    private static var lockScreenGlance: [WidgetFamily] {
        #if os(iOS)
        [.accessoryCircular, .accessoryRectangular]
        #else
        []
        #endif
    }

    private static var lockScreenCount: [WidgetFamily] {
        #if os(iOS)
        [.accessoryCircular]
        #else
        []
        #endif
    }

    private static var lockScreenText: [WidgetFamily] {
        #if os(iOS)
        [.accessoryRectangular, .accessoryInline]
        #else
        []
        #endif
    }

    private static var lockScreen: [WidgetFamily] {
        #if os(iOS)
        [.accessoryRectangular, .accessoryInline, .accessoryCircular]
        #else
        []
        #endif
    }
}
