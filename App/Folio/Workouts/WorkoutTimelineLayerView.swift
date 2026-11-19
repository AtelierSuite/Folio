import Planner
import SwiftUI

struct WorkoutTimelineLayerView: View {
    @Environment(WorkoutStore.self) private var store
    let context: TimelineLayerContext
    @State private var workouts: [Workout] = []
    @State private var width: CGFloat = 0
    @ScaledMetric(relativeTo: .caption2) private var labelHeight: CGFloat = 18
    @ScaledMetric(relativeTo: .caption2) private var minimumLabelWidth: CGFloat = 26

    var body: some View {
        TimelineSlotLayout(dayCount: context.days.count, hourHeight: context.hourHeight) {
            ForEach(blocks) { block in
                WorkoutBlockView()
                    .timelineSlot(TimelineSlot(block.segment))
            }
            ForEach(labels) { label in
                WorkoutBlockLabel(activity: label.activity)
                    .timelineSlot(label.slot)
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHidden(workouts.isEmpty)
        .task(id: LoadKey(revision: store.revision, isActive: store.isActive, span: context.days.span)) {
            await load()
        }
    }

    private var blocks: [WorkoutBlock] {
        workouts.flatMap { workout in
            context.days.segments(from: workout.interval.start, to: workout.interval.end)
                .map { WorkoutBlock(activity: workout.activity, segment: $0) }
        }
    }

    /// Each workout is labelled once, in the first spot where the label won't run under an event card.
    private var labels: [WorkoutLabel] {
        let dayWidth = width / CGFloat(max(context.days.count, 1))
        guard dayWidth > 0, context.hourHeight > 0 else { return [] }
        let heightHours = Double(labelHeight / context.hourHeight)
        let minimumWidthFraction = Double(minimumLabelWidth / dayWidth)
        return workouts.compactMap { workout in
            let segments = context.days.segments(from: workout.interval.start, to: workout.interval.end)
            let slot = segments.lazy.compactMap { segment in
                context.clearLabelSlot(
                    in: segment, heightHours: heightHours, minimumWidthFraction: minimumWidthFraction
                )
            }.first
            return slot.map { WorkoutLabel(id: workout.id, activity: workout.activity, slot: $0) }
        }
    }

    private var accessibilityLabel: String {
        workouts.map { workout in
            String(
                format: String(localized: "Timeline.Accessibility", table: "Workouts"),
                workout.activity.title,
                workout.interval.start.formatted(date: .omitted, time: .shortened),
                workout.interval.end.formatted(date: .omitted, time: .shortened)
            )
        }
        .joined(separator: ", ")
    }

    private func load() async {
        guard store.isActive, let span = context.days.span else {
            workouts = []
            return
        }
        workouts = await store.workouts(in: span)
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let isActive: Bool
        let span: DateInterval?
    }
}

private struct WorkoutBlock: Identifiable {
    let activity: WorkoutActivity
    let segment: TimelineDaySegment

    var id: TimelineDaySegment { segment }
}

private struct WorkoutLabel: Identifiable {
    let id: UUID
    let activity: WorkoutActivity
    let slot: TimelineSlot
}
