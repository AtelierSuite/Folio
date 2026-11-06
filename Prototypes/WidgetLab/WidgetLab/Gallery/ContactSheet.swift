import SwiftUI

/// One row per idea with every family side by side, for reviewing the lot in a single image.
struct ContactSheet: View {
    let title: String
    let ideas: [LabIdea]
    let snapshot: LabSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title).font(.title3.weight(.bold))
            ForEach(ideas) { idea in
                VStack(alignment: .leading, spacing: 8) {
                    IdeaHeader(idea: idea)
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(idea.widgets) { spec in
                            WidgetCard(family: spec.family) { spec.render(snapshot) }
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(width: 1020, alignment: .leading)
        .background(Color(.systemGroupedBackground))
    }
}
