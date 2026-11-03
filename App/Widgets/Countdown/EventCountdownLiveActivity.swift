#if os(iOS)
import ActivityKit
import Planner
import SwiftUI
import WidgetKit

struct EventCountdownLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EventCountdownAttributes.self) { context in
            CountdownLockScreenView(state: context.state, phase: phase(of: context))
                .background {
                    LinearGradient(
                        colors: [context.state.color.color.opacity(0.1), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .activityBackgroundTint(.clear)
                .widgetURL(context.attributes.eventURL(for: context.state))
        } dynamicIsland: { context in
            CountdownDynamicIsland.make(context: context, phase: phase(of: context))
        }
    }

    private func phase(of context: ActivityViewContext<EventCountdownAttributes>) -> CountdownPhase {
        CountdownPhase(state: context.state, startedAt: context.attributes.startedAt, isStale: context.isStale)
    }
}
#endif
