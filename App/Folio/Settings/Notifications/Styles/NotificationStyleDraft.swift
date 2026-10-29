import Planner
import SwiftUI

struct NotificationStyleDraft {
    var style: NotificationAlertStyle?
    private let originalStyle: NotificationAlertStyle?

    init(reference: CalendarItemReference?, settings: NotificationStyleSettings = .shared) {
        originalStyle = reference.flatMap(settings.styleOverride(for:))
        style = originalStyle
    }

    var hasChanges: Bool {
        style != originalStyle
    }

    func save(for reference: CalendarItemReference, in scheduler: NotificationScheduler) {
        guard hasChanges else { return }
        let style = style
        Task { await scheduler.setStyleOverride(style, for: reference) }
    }
}
