import SwiftUI

/// Ticks on its own through `Text(timerInterval:)`, so the app never has to send updates.
struct CountdownTimerText: View {
    let phase: CountdownPhase

    var body: some View {
        if let interval = phase.interval {
            Text(timerInterval: interval, countsDown: true)
                .monospacedDigit()
        } else {
            Text(phase.title)
        }
    }
}
