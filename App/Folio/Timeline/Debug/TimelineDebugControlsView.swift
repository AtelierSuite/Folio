#if DEBUG
import SwiftUI

struct TimelineDebugControlsView: View {
    @Binding var dayCount: Int
    @Binding var scenario: TimelineDebugScenario
    @Binding var dayOffset: Int
    @Binding var hourHeight: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Picker(String(localized: "Debug.Days", table: "Timeline"), selection: $dayCount) {
                    Text(String(localized: "Debug.OneDay", table: "Timeline")).tag(1)
                    Text(String(localized: "Debug.ThreeDays", table: "Timeline")).tag(3)
                    Text(String(localized: "Debug.SevenDays", table: "Timeline")).tag(7)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                Picker(String(localized: "Debug.Scenario", table: "Timeline"), selection: $scenario) {
                    ForEach(TimelineDebugScenario.allCases) { scenario in
                        Text(scenario.title).tag(scenario)
                    }
                }
                .labelsHidden()
                .fixedSize()
            }
            HStack {
                Button(String(localized: "Debug.PreviousDay", table: "Timeline"), systemImage: "chevron.left") {
                    dayOffset -= 1
                }
                Button(String(localized: "Debug.NextDay", table: "Timeline"), systemImage: "chevron.right") {
                    dayOffset += 1
                }
                Slider(value: $hourHeight, in: 20...120) {
                    Text(String(localized: "Debug.HourHeight", table: "Timeline"))
                }
            }
            .labelStyle(.iconOnly)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
#endif
