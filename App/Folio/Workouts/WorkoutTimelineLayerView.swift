import Planner
import SwiftUI

struct WorkoutTimelineLayerView: View {
    @Environment(WorkoutStore.self) private var store
    let context: TimelineLayerContext
    @State private var workouts: [Workout] = []

    var body: some View {
        TimelineSlotLayout(dayCount: context.days.count, hourHeight: context.hourHeight) {
            ForEach(blocks) { block in
                WorkoutBlockView(activity: block.activity, showsLabel: block.isFirst)
                    .timelineSlot(TimelineSlot(block.segment))
            }
        }
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
                .enumerated()
                .map { index, segment in
                    WorkoutBlock(activity: workout.activity, isFirst: index == 0, segment: segment)
                }
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
    let isFirst: Bool
    let segment: TimelineDaySegment

    var id: TimelineDaySegment { segment }
}
