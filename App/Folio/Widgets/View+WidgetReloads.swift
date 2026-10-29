import Planner
import SwiftUI
import WidgetKit

extension View {
    /// Keeps the widgets in step with the app's calendar data and settings.
    func reloadsWidgets(on store: CalendarStore) -> some View {
        task(id: store.contentRevision) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
