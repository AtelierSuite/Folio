import Planner
import SwiftUI

struct MedicationTimelineLayerView: View {
    private static let markerHeight: CGFloat = 18

    @Environment(MedicationStore.self) private var store
    let context: TimelineLayerContext
    @State private var doses: [MedicationDose] = []

    var body: some View {
        TimelineSlotLayout(
            dayCount: context.days.count,
            hourHeight: context.hourHeight,
            minimumHeight: Self.markerHeight
        ) {
            ForEach(MedicationDoseMarker.markers(for: doses)) { marker in
                if let position = context.days.position(of: marker.date) {
                    MedicationDoseMarkerView(marker: marker)
                        .timelineSlot(TimelineSlot(
                            dayIndex: position.dayIndex,
                            startHour: position.hour,
                            endHour: position.hour
                        ))
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(marker.accessibilityLabel)
                        .accessibilityIdentifier("MedicationDoseMarker")
                }
            }
        }
        .allowsHitTesting(false)
        .task(id: LoadKey(
            revision: store.revision,
            isShown: store.isShownOnTimeline,
            span: context.days.span
        )) {
            await load()
        }
    }

    private func load() async {
        guard store.isShownOnTimeline, let span = context.days.span else {
            doses = []
            return
        }
        doses = await store.doses(in: span)
    }

    private struct LoadKey: Equatable {
        let revision: Int
        let isShown: Bool
        let span: DateInterval?
    }
}
