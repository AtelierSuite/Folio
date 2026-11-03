import Planner
import SwiftUI

/// A line across the day at the alarm's time, with a badge that offers to delete it.
struct StandaloneAlarmMarkerView: View {
    static let height: CGFloat = 20

    @Environment(StandaloneAlarmCenter.self) private var center
    let alarm: StandaloneAlarm

    var body: some View {
        ZStack(alignment: .trailing) {
            Rectangle()
                .fill(Color.orange)
                .frame(height: 1.5)
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)
            Menu {
                Section(alarm.title) {
                    Button(
                        String(localized: "Marker.Delete", table: "StandaloneAlarms"),
                        systemImage: "trash",
                        role: .destructive
                    ) {
                        Task { await center.remove(alarm) }
                    }
                }
            } label: {
                StandaloneAlarmBadge(time: time)
            }
            .accessibilityLabel(String(
                format: String(localized: "Marker.Accessibility", table: "StandaloneAlarms"), alarm.title, time
            ))
            .accessibilityIdentifier("StandaloneAlarmMarker")
            .padding(.trailing, 2)
        }
        .frame(height: Self.height)
    }

    private var time: String {
        alarm.fireDate.formatted(date: .omitted, time: .shortened)
    }
}

private struct StandaloneAlarmBadge: View {
    let time: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Label(time, systemImage: "alarm.fill")
            Image(systemName: "alarm.fill")
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 6)
        .frame(height: StandaloneAlarmMarkerView.height)
        .background(Color.orange, in: Capsule())
        .fixedSize(horizontal: false, vertical: true)
    }
}
