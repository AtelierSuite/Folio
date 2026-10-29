import Planner
import SwiftUI

struct SleepTimelineLayerView: View {
    @Environment(SleepStore.self) private var store
    let context: TimelineLayerContext
    @State private var sessions: [SleepSession] = []

    var body: some View {
        TimelineSlotLayout(dayCount: context.days.count, hourHeight: context.hourHeight) {
            ForEach(blocks) { block in
                SleepBlockView(stage: block.stage, showsIcon: block.isSessionStart)
                    .timelineSlot(TimelineSlot(block.segment))
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
            let daySegments = session.segments.flatMap { segment in
                context.days.segments(from: segment.interval.start, to: segment.interval.end)
                    .map { (stage: segment.stage, daySegment: $0) }
            }
            return daySegments.enumerated().map { index, item in
                SleepBlock(stage: item.stage, segment: item.daySegment, isSessionStart: index == 0)
            }
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
    let stage: SleepStage
    let segment: TimelineDaySegment
    let isSessionStart: Bool

    var id: TimelineDaySegment { segment }
}
