#if canImport(AlarmKit) && os(iOS)
import ActivityKit
import AlarmKit
import Planner
import SwiftUI
import WidgetKit

/// AlarmKit shows this while an alarm is snoozed, between rings.
struct FolioAlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<FolioAlarmMetadata>.self) { context in
            AlarmLockScreenView(
                title: title(of: context), mode: context.state.mode, tint: context.attributes.tintColor
            )
            .widgetURL(context.attributes.metadata?.link)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    AlarmModeIcon(mode: context.state.mode)
                        .font(.title2)
                        .foregroundStyle(context.attributes.tintColor)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    AlarmCountdownText(mode: context.state.mode)
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: 110, alignment: .trailing)
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(title(of: context))
                        .font(.headline)
                        .lineLimit(1)
                }
            } compactLeading: {
                AlarmModeIcon(mode: context.state.mode)
                    .foregroundStyle(context.attributes.tintColor)
            } compactTrailing: {
                AlarmCountdownText(mode: context.state.mode)
                    .frame(maxWidth: 56)
                    .foregroundStyle(context.attributes.tintColor)
            } minimal: {
                AlarmModeIcon(mode: context.state.mode)
                    .foregroundStyle(context.attributes.tintColor)
            }
            .widgetURL(context.attributes.metadata?.link)
            .keylineTint(context.attributes.tintColor)
        }
    }

    private func title(of context: ActivityViewContext<AlarmAttributes<FolioAlarmMetadata>>) -> String {
        context.attributes.metadata?.title ?? String(localized: context.attributes.presentation.alert.title)
    }
}
#endif
