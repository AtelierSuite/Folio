import Planner
import SwiftUI

extension View {
    /// Opens the tab, note, day or countdown the requested screenshot shows. Does nothing outside Debug builds.
    @ViewBuilder
    func stagesScreenshot(selectedTab: Binding<AppTab>, router: AppRouter) -> some View {
        #if DEBUG
        if let stage = ScreenshotStage.requested {
            modifier(ScreenshotStageModifier(stage: stage, selectedTab: selectedTab, router: router))
        } else {
            self
        }
        #else
        self
        #endif
    }

    /// Selects the reminder list the Lists screenshot shows.
    @ViewBuilder
    func selectsScreenshotList(_ selection: Binding<String?>) -> some View {
        #if DEBUG
        if ScreenshotStage.requested == .lists {
            modifier(ScreenshotListSelection(selection: selection))
        } else {
            self
        }
        #else
        self
        #endif
    }
}

#if DEBUG
private struct ScreenshotStageModifier: ViewModifier {
    @Environment(CalendarStore.self) private var calendarStore
    @Environment(NotesLibrary.self) private var notesLibrary
    @Environment(EventCountdownManager.self) private var countdowns
    let stage: ScreenshotStage
    @Binding var selectedTab: AppTab
    let router: AppRouter

    func body(content: Content) -> some View {
        content
            .task {
                selectedTab = stage.tab
                switch stage {
                case .alarms:
                    router.open(.calendarDay(ScreenshotSamples.nextWeekday(after: .now, calendar: .current)))
                case .notes:
                    await openFirstNote()
                case .countdown:
                    await startCountdown()
                case .week, .lists, .notifications:
                    break
                }
            }
    }

    private func openFirstNote() async {
        await notesLibrary.start()
        guard let title = ScreenshotSamples.current.notes.first?.title,
              let url = notesLibrary.screenshotNoteURL(titled: title) else { return }
        for _ in 0..<50 where !notesLibrary.notes.contains(where: { $0.url == url }) {
            try? await Task.sleep(for: .milliseconds(200))
        }
        router.open(.note(url))
    }

    private func startCountdown() async {
        let title = ScreenshotSamples.current.countdown.title
        let now = Date.now
        for _ in 0..<50 {
            let events = await calendarStore.events(in: DateInterval(start: now, duration: 2 * 3600))
            if let event = events.first(where: { $0.title == title }) {
                try? countdowns.start(event)
                return
            }
            try? await Task.sleep(for: .milliseconds(200))
        }
    }
}

private struct ScreenshotListSelection: ViewModifier {
    @Environment(CalendarStore.self) private var store
    @Binding var selection: String?

    func body(content: Content) -> some View {
        content
            .onChange(of: store.reminderLists, initial: true) { _, lists in
                guard let title = ScreenshotSamples.current.calendars.first(where: { $0.key == "study" })?.title,
                      let list = lists.first(where: { $0.title == title }), selection != list.id else { return }
                selection = list.id
            }
    }
}
#endif
