import Planner
import SwiftUI

struct SleepTimelineLayerView: View {
    @Environment(SleepStore.self) private var store
    let context: TimelineLayerContext
    @State private var sessions: [SleepSession] = []
    @State private var width: CGFloat = 0
    @ScaledMetric(relativeTo: .caption2) private var labelHeight: CGFloat = 18
    @ScaledMetric(relativeTo: .caption2) private var minimumLabelWidth: CGFloat = 28

    var body: some View {
        TimelineSlotLayout(dayCount: context.days.count, hourHeight: context.hourHeight) {
            ForEach(blocks) { block in
                SleepBlockView(isAsleep: block.isAsleep)
                    .timelineSlot(TimelineSlot(block.segment))
            }
            ForEach(summaries) { summary in
                SleepSummaryLabel(asleepDuration: summary.asleepDuration)
                    .timelineSlot(summary.slot)
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHidden(sessions.isEmpty)
        .task(id: LoadKey(revision: store.revision, isActive: store.isActive, span: context.days.span)) {
            await load()
        }
    }

    private var blocks: [SleepBlock] {
        sessions.flatMap { session in
            let daySegments = session.stretches.flatMap { stretch in
                context.days.segments(from: stretch.interval.start, to: stretch.interval.end)
                    .map { (isAsleep: stretch.isAsleep, daySegment: $0) }
            }
            return daySegments.map { item in
                SleepBlock(isAsleep: item.isAsleep, segment: item.daySegment)
            }
        }
    }

    /// Each session is labelled once, in the first spot where the label won't run under an event card.
    private var summaries: [SleepSessionLabel] {
        let dayWidth = width / CGFloat(max(context.days.count, 1))
        guard dayWidth > 0, context.hourHeight > 0 else { return [] }
        let heightHours = Double(labelHeight / context.hourHeight)
        let minimumWidthFraction = Double(minimumLabelWidth / dayWidth)
        return sessions.compactMap { session in
            let segments = context.days.segments(from: session.interval.start, to: session.interval.end)
            let slot = segments.lazy.compactMap { segment in
                context.clearLabelSlot(
                    in: segment, heightHours: heightHours, minimumWidthFraction: minimumWidthFraction
                )
            }.first
            return slot.map { SleepSessionLabel(id: session.id, asleepDuration: session.asleepDuration, slot: $0) }
        }
    }

    private var accessibilityLabel: String {
        sessions.map { session in
            String(
                format: String(localized: "Timeline.Accessibility", table: "Sleep"),
                session.interval.start.formatted(date: .omitted, time: .shortened),
                session.interval.end.formatted(date: .omitted, time: .shortened)
            )
        }
        .joined(separator: ", ")
    }

    private func load() async {
        guard store.isActive, let span = context.days.span else {
            sessions = []
            return
        }
        sessions = await store.sessions(in: span)
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let isActive: Bool
        let span: DateInterval?
    }
}

private struct SleepBlock: Identifiable {
    let isAsleep: Bool
    let segment: TimelineDaySegment

    var id: TimelineDaySegment { segment }
}

private struct SleepSessionLabel: Identifiable {
    let id: SleepSession.ID
    let asleepDuration: TimeInterval
    let slot: TimelineSlot
}
