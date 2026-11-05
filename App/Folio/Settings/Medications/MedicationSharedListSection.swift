import Planner
import SwiftUI

struct MedicationSharedListSection: View {
    @Environment(MedicationStore.self) private var store
    @State private var medications: [Medication] = []

    var body: some View {
        if store.isActive {
            Section {
                if medications.isEmpty {
                    Text(String(localized: "Settings.Empty", table: "Medications"))
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("MedicationEmptyState")
                }
                ForEach(medications) { medication in
                    Text(medication.name)
                }
                Button(String(localized: "Settings.Choose", table: "Medications")) {
                    Task { await store.requestAccess() }
                }
                .accessibilityIdentifier("MedicationChooseButton")
            } header: {
                Text(String(localized: "Settings.SharedHeader", table: "Medications"))
            }
            .task(id: store.revision) {
                medications = await store.scheduledMedications()
            }
        }
    }
}
