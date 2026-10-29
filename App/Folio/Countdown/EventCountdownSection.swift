import Planner
import SwiftUI

/// Starts or stops the event's Live Activity countdown. Hidden where Live Activities aren't
/// available and for events that can't be counted down to at all.
struct EventCountdownSection: View {
    let event: CalendarEvent
    @Environment(EventCountdownManager.self) private var countdowns
    @Environment(\.platformCapabilities) private var capabilities
    @State private var isShowingStartError = false

    var body: some View {
        if capabilities.supports(.liveActivityCountdown) {
            TimelineView(.everyMinute) { context in
                section(at: context.date)
            }
            .alert(String(localized: "Countdown.StartFailed", table: "Countdown"), isPresented: $isShowingStartError) {
                Button(String(localized: "OK", table: "Countdown"), role: .cancel) {}
            } message: {
                Text(String(localized: "Countdown.TurnedOff", table: "Countdown"))
            }
        }
    }

    @ViewBuilder
    private func section(at date: Date) -> some View {
        if countdowns.isCountingDown(event) {
            Section {
                Button(String(localized: "Countdown.Stop", table: "Countdown"), systemImage: "stop.circle") {
                    Task { await countdowns.stop(event) }
                }
                .accessibilityIdentifier("EventCountdownButton")
            }
        } else {
            switch countdowns.availability(for: event, at: date) {
            case .available:
                Section {
                    startButton
                }
            case .notYet:
                Section {
                    startButton
                        .disabled(true)
                } footer: {
                    Text(String(localized: "Countdown.AvailableLater", table: "Countdown"))
                }
            case .unavailable:
                EmptyView()
            }
        }
    }

    private var startButton: some View {
        Button(String(localized: "Countdown.Start", table: "Countdown"), systemImage: "timer") {
            do {
                try countdowns.start(event)
            } catch {
                isShowingStartError = true
            }
        }
        .accessibilityIdentifier("EventCountdownButton")
    }
}
