import Planner
import SwiftUI

extension View {
    /// Needs the scene's `AppRouter` in the environment.
    func handlesNotificationRoutes() -> some View {
        modifier(NotificationRouteHandler())
    }
}

private struct NotificationRouteHandler: ViewModifier {
    @Environment(NotificationNavigator.self) private var navigator
    @Environment(AppRouter.self) private var router
    @Environment(NotesLibrary.self) private var library
    @Environment(CalendarStore.self) private var calendarStore
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onChange(of: request, initial: true) { _, request in
                guard request.isActive, let route = request.route else { return }
                navigator.pendingRoute = nil
                show(route)
            }
    }

    private var request: RouteRequest {
        RouteRequest(route: navigator.pendingRoute, isActive: scenePhase == .active)
    }

    private func show(_ route: NotificationRoute) {
        switch route {
        case .item(let destination, let meetingURL):
            router.open(destination)
            if let meetingURL {
                openURL(meetingURL)
            }
        case .url(let url):
            openURL(url)
        case .note(let target):
            Task { await openNote(target) }
        }
    }

    private func openNote(_ target: NotificationNoteTarget) async {
        await library.start()
        let actions = LinkedNoteActions(library: library, calendarStore: calendarStore, router: router)
        switch target {
        case .event(let reference, let date):
            if let event = await calendarStore.event(matching: reference, near: date) {
                if (try? await actions.openNote(for: event)) == nil {
                    router.open(.calendarDay(date, item: reference))
                }
            } else {
                await openDailyNote(on: date, with: actions)
            }
        case .dailyNote(let date):
            await openDailyNote(on: date, with: actions)
        }
    }

    private func openDailyNote(on date: Date, with actions: LinkedNoteActions) async {
        if (try? await actions.openDailyNote(on: date)) == nil {
            router.open(.calendarDay(date))
        }
    }

    private struct RouteRequest: Equatable {
        let route: NotificationRoute?
        let isActive: Bool
    }
}
