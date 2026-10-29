import Planner
import SwiftUI

extension View {
    /// Opens `folio://day/…`, `folio://event/…` and `folio://new/…` links from widgets, and requests from
    /// the Control Center controls.
    func opensCalendarDeepLinks(with router: AppRouter) -> some View {
        modifier(CalendarDeepLinkHandler(router: router))
    }
}

private struct CalendarDeepLinkHandler: ViewModifier {
    @Environment(AppDestinationRequests.self) private var requests
    let router: AppRouter

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                if let destination = CalendarDeepLink.destination(from: url) {
                    router.open(destination)
                }
            }
            .onChange(of: requests.pendingDestination, initial: true) { _, destination in
                if let destination {
                    requests.pendingDestination = nil
                    router.open(destination)
                }
            }
    }
}
