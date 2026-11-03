import SwiftUI

/// Ticks on its own through `Text(timerInterval:)`, so the app never has to send updates.
/// That text always fills the width it is offered, so a hidden placeholder sizes it instead.
struct CountdownTimerText: View {
    let phase: CountdownPhase

    var body: some View {
        if let interval = phase.interval {
            Text(placeholder(for: interval))
                .hidden()
                .overlay(alignment: .trailing) {
                    Text(timerInterval: interval, countsDown: true)
                        .multilineTextAlignment(.trailing)
                }
                .monospacedDigit()
        } else {
            Text(phase.title)
        }
    }

    private func placeholder(for interval: ClosedRange<Date>) -> String {
        interval.upperBound.timeIntervalSinceNow >= 60 * 60 ? "0:00:00" : "00:00"
    }
}
