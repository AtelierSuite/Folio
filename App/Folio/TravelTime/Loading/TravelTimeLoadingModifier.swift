import Planner
import SwiftUI

struct TravelTimeLoadingModifier: ViewModifier {
    @Environment(TravelTimeStore.self) private var store
    let events: [CalendarEvent]
    @Binding var estimates: [String: TravelEstimate]

    private let refreshInterval: Duration = .seconds(5 * 60)

    func body(content: Content) -> some View {
        content
            .task(id: LoadKey(events: events, revision: store.revision)) {
                while !Task.isCancelled {
                    let loaded = await store.estimates(for: events)
                    guard !Task.isCancelled else { return }
                    estimates = loaded
                    try? await Task.sleep(for: refreshInterval)
                }
            }
    }

    private struct LoadKey: Equatable {
        let events: [CalendarEvent]
        let revision: Int
    }
}

extension View {
    func loadsTravelTimes(for events: [CalendarEvent], into estimates: Binding<[String: TravelEstimate]>) -> some View {
        modifier(TravelTimeLoadingModifier(events: events, estimates: estimates))
    }
}
