#if os(iOS)
import ActivityKit
import Planner
import SwiftUI
import WidgetKit

struct EventCountdownLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EventCountdownAttributes.self) { context in
            CountdownLockScreenView(state: context.state, phase: phase(of: context))
                .widgetURL(context.attributes.eventURL(for: context.state))
        } dynamicIsland: { context in
            let phase = phase(of: context)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    CountdownProgressRing(phase: phase, color: context.state.color)
                        .frame(width: 36, height: 36)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CountdownTimerText(phase: phase)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 110, alignment: .trailing)
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    CountdownIslandFooter(state: context.state, phase: phase)
                }
            } compactLeading: {
                CountdownProgressRing(phase: phase, color: context.state.color)
            } compactTrailing: {
                CountdownTimerText(phase: phase)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 56)
                    .foregroundStyle(context.state.color.color)
            } minimal: {
                CountdownProgressRing(phase: phase, color: context.state.color)
            }
            .widgetURL(context.attributes.eventURL(for: context.state))
            .keylineTint(context.state.color.color)
        }
    }

    private func phase(of context: ActivityViewContext<EventCountdownAttributes>) -> CountdownPhase {
        CountdownPhase(state: context.state, startedAt: context.attributes.startedAt, isStale: context.isStale)
    }
}
#endif
