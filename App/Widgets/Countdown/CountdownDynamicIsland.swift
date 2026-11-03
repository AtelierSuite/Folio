#if os(iOS)
import ActivityKit
import Planner
import SwiftUI
import WidgetKit

enum CountdownDynamicIsland {
    static func make(
        context: ActivityViewContext<EventCountdownAttributes>,
        phase: CountdownPhase
    ) -> DynamicIsland {
        let state = context.state
        return DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                CountdownIslandEventSummary(state: state)
                    .dynamicIsland(verticalPlacement: .belowIfTooWide)
            }
            DynamicIslandExpandedRegion(.trailing) {
                CountdownIslandTimer(phase: phase, color: state.color)
                    .dynamicIsland(verticalPlacement: .belowIfTooWide)
            }
            DynamicIslandExpandedRegion(.bottom) {
                CountdownIslandProgressBar(phase: phase, color: state.color)
            }
        } compactLeading: {
            CountdownProgressRing(phase: phase, color: state.color)
                .padding(2)
        } compactTrailing: {
            CountdownTimerText(phase: phase)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(state.color.color)
        } minimal: {
            CountdownProgressRing(phase: phase, color: state.color)
                .padding(2)
        }
        .widgetURL(context.attributes.eventURL(for: state))
        .keylineTint(state.color.color)
    }
}
#endif
