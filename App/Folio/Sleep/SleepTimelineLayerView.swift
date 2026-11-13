import Planner
import SwiftUI

struct SleepTimelineLayerView: View {
    @Environment(SleepStore.self) private var store
    let context: TimelineLayerContext
    @State private var sessions: [SleepSession] = []

    var body: some View {
        TimelineSlotLayout(dayCount: context.days.count, hourHeight: context.hourHeight) {
            ForEach(blocks) { block in
                SleepBlockView(isAsleep: block.isAsleep)
                    .timelineSlot(TimelineSlot(block.segment))
            }
            ForEach(summaries) { summary in
                SleepSummaryLabel(asleepDuration: summary.asleepDuration)
                    .timelineSlot(TimelineSlot(summary.segment))
            }
        }
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

    private var summaries: [SleepSessionLabel] {
        sessions.compactMap { session in
            guard let segment = context.days.segments(
                from: session.interval.start, to: session.interval.end
            ).first else { return nil }
            return SleepSessionLabel(asleepDuration: session.asleepDuration, segment: segment)
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
    let asleepDuration: TimeInterval
    let segment: TimelineDaySegment

    var id: TimelineDaySegment { segment }
}
