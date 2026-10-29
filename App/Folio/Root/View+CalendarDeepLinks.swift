import Planner
import SwiftUI

extension View {
    /// Opens `folio://day/…`, `folio://event/…` and `folio://new/…` links from widgets and controls.
    func opensCalendarDeepLinks(with router: AppRouter) -> some View {
        onOpenURL { url in
            if let destination = CalendarDeepLink.destination(from: url) {
                router.open(destination)
            }
        }
    }
}
