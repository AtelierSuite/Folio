import SwiftUI

struct GalleryView: View {
    @State private var minuteOfDay = Double(LabClock.defaultMinuteOfDay)
    @State private var scenario = LabScenario.busy

    private var snapshot: LabSnapshot {
        scenario.snapshot(minuteOfDay: Int(minuteOfDay))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 26) {
                ForEach(LabIdea.catalog) { IdeaSection(idea: $0, snapshot: snapshot) }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .top, spacing: 0) { controls }
    }

    private var controls: some View {
        VStack(spacing: 6) {
            Picker("Scenario", selection: $scenario) {
                ForEach(LabScenario.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            HStack {
                Text(LabFormat.time(snapshot.now)).monospacedDigit().font(.subheadline.weight(.semibold))
                Slider(value: $minuteOfDay, in: 0...1439, step: 1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.bar)
    }
}
