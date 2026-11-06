import SwiftUI

struct IdeaHeader: View {
    let idea: LabIdea

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(idea.number). \(idea.name)").font(.headline)
            Text(idea.summary).font(.subheadline).foregroundStyle(.secondary)
            Text(idea.dataNeeded).font(.caption).foregroundStyle(.tertiary)
        }
    }
}

struct IdeaSection: View {
    let idea: LabIdea
    let snapshot: LabSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            IdeaHeader(idea: idea).padding(.horizontal, 16)
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(idea.widgets) { spec in
                        WidgetCard(family: spec.family) { spec.render(snapshot) }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
            .scrollIndicators(.hidden)
        }
    }
}
